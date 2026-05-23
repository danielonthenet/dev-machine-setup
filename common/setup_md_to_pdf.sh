#!/bin/bash
# Shared helpers for configuring md-to-pdf with Mermaid and MathJax support.

md_to_pdf_support_config_dir() {
    echo "${XDG_CONFIG_HOME:-$HOME/.config}/md-to-pdf"
}

md_to_pdf_support_vendor_dir() {
    echo "$(md_to_pdf_support_config_dir)/vendor"
}

md_to_pdf_support_copy_tree() {
    local source_dir="$1"
    local target_dir="$2"

    mkdir -p "$target_dir"

    if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete "$source_dir/" "$target_dir/"
    else
        rm -rf "$target_dir"
        mkdir -p "$target_dir"
        cp -R "$source_dir"/. "$target_dir"/
    fi
}

md_to_pdf_support_select_file() {
    local package_dir="$1"
    shift

    local candidate=""
    for candidate in "$@"; do
        if [[ -f "$package_dir/$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

write_md_to_pdf_support_config() {
    local config_file="$1"
    local mermaid_url="$2"
    local mermaid_mode="$3"
    local mathjax_url="$4"

    mkdir -p "$(dirname "$config_file")"

    cat > "$config_file" <<'EOF'
module.exports = {
    marked_extensions: [
        {
            extensions: [
                {
                    name: 'mathBlock',
                    level: 'block',
                    start(src) {
                        const dollarMatch = src.match(/^ {0,3}\$\$/m);
                        const bracketMatch = src.match(/^ {0,3}\\\[/m);
                        const indexes = [dollarMatch?.index, bracketMatch?.index].filter((value) => value !== undefined);
                        return indexes.length > 0 ? Math.min(...indexes) : undefined;
                    },
                    tokenizer(src) {
                        const patterns = [
                            {
                                regex: /^ {0,3}\$\$[ \t]*\n([\s\S]+?)\n {0,3}\$\$(?:\n|$)/,
                                open: '$$',
                                close: '$$',
                            },
                            {
                                regex: /^ {0,3}\\\[[ \t]*\n([\s\S]+?)\n {0,3}\\\](?:\n|$)/,
                                open: '\\[',
                                close: '\\]',
                            },
                        ];

                        for (const pattern of patterns) {
                            const match = src.match(pattern.regex);
                            if (match) {
                                return {
                                    type: 'mathBlock',
                                    raw: match[0],
                                    math: match[1],
                                    openDelimiter: pattern.open,
                                    closeDelimiter: pattern.close,
                                };
                            }
                        }
                    },
                    renderer(token) {
                        const escapeHtml = (value) => value
                            .replaceAll('&', '&amp;')
                            .replaceAll('<', '&lt;')
                            .replaceAll('>', '&gt;');

                        return '<div class="math-display">'
                            + token.openDelimiter
                            + '\n'
                            + escapeHtml(token.math)
                            + '\n'
                            + token.closeDelimiter
                            + '</div>';
                    },
                },
            ],
        },
    ],
    script: [
        {
            content: String.raw`
                window.MathJax = {
                    tex: {
                        inlineMath: { '[+]': [['$', '$']] },
                        displayMath: [['$$', '$$'], ['\\\\[', '\\\\]']],
                        processEscapes: true,
                        processEnvironments: true,
                    },
                    options: {
                        skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code'],
                    },
                };
            `,
        },
        {
            type: 'module',
            content: String.raw`
                const MERMAID_URL = '__MERMAID_URL__';
                const MERMAID_MODE = '__MERMAID_MODE__';
                const MATHJAX_URL = '__MATHJAX_URL__';

                const loadScript = (src) =>
                    new Promise((resolve, reject) => {
                        const script = document.createElement('script');
                        script.src = src;
                        script.onload = () => resolve();
                        script.onerror = () => reject(new Error('Failed to load ' + src));
                        document.head.appendChild(script);
                    });

                if (MERMAID_MODE === 'esm') {
                    const mermaidModule = await import(MERMAID_URL);
                    window.mermaid = mermaidModule.default ?? mermaidModule;
                } else {
                    await loadScript(MERMAID_URL);
                }

                if (!window.mermaid) {
                    throw new Error('Mermaid failed to initialize.');
                }

                for (const codeBlock of document.querySelectorAll('pre code.language-mermaid, pre code.lang-mermaid, pre code.mermaid')) {
                    const diagramBlock = document.createElement('pre');
                    diagramBlock.className = 'mermaid';
                    diagramBlock.textContent = codeBlock.textContent;
                    codeBlock.parentElement.replaceWith(diagramBlock);
                }

                const mermaidNodes = document.querySelectorAll('pre.mermaid');

                window.mermaid.initialize({
                    startOnLoad: false,
                    securityLevel: 'strict',
                });

                await loadScript(MATHJAX_URL);

                if (!window.MathJax) {
                    throw new Error('MathJax failed to initialize.');
                }

                await window.MathJax.startup.promise;
                await window.mermaid.run({
                    nodes: mermaidNodes,
                    suppressErrors: false,
                });
                await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
            `,
        },
    ],
    css: String.raw`
        .math-display {
            margin: 1em 0;
        }

        pre.mermaid {
            background: transparent;
            border: 0;
            margin: 1.25rem 0;
            padding: 0;
            white-space: normal;
        }

        pre.mermaid svg {
            display: block;
            height: auto;
            max-width: 100%;
        }

        mjx-container[jax="SVG"] {
            overflow-x: auto;
            overflow-y: hidden;
            padding: 0.15rem 0;
        }
    `,
    pdf_options: {
        printBackground: true,
    },
};
EOF

    sed -i.bak \
        -e "s|__MERMAID_URL__|$mermaid_url|g" \
        -e "s|__MERMAID_MODE__|$mermaid_mode|g" \
        -e "s|__MATHJAX_URL__|$mathjax_url|g" \
        "$config_file"
    rm -f "$config_file.bak"
}

setup_md_to_pdf_support() {
    if ! command -v npm >/dev/null 2>&1; then
        echo "⚠️  npm not found. Skipping md-to-pdf global configuration."
        return 1
    fi

    local npm_root=""
    npm_root="$(npm root -g)"

    local mermaid_package_dir="$npm_root/mermaid"
    local mathjax_package_dir="$npm_root/mathjax"

    if [[ ! -d "$mermaid_package_dir" || ! -d "$mathjax_package_dir" ]]; then
        echo "⚠️  Mermaid or MathJax is not installed globally yet. Skipping md-to-pdf global configuration."
        return 1
    fi

    local mermaid_relative_path=""
    local mermaid_mode=""
    mermaid_relative_path="$(md_to_pdf_support_select_file "$mermaid_package_dir" \
        "dist/mermaid.min.js" \
        "dist/mermaid.esm.min.mjs" \
        "dist/mermaid.esm.mjs")" || {
        echo "⚠️  Could not find a Mermaid browser bundle in $mermaid_package_dir"
        return 1
    }

    if [[ "$mermaid_relative_path" == *.mjs ]]; then
        mermaid_mode="esm"
    else
        mermaid_mode="global"
    fi

    local mathjax_relative_path=""
    mathjax_relative_path="$(md_to_pdf_support_select_file "$mathjax_package_dir" \
        "tex-svg.js" \
        "tex-chtml.js" \
        "es5/tex-svg.js" \
        "es5/tex-chtml.js")" || {
        echo "⚠️  Could not find a MathJax browser bundle in $mathjax_package_dir"
        return 1
    }

    local config_dir=""
    local vendor_dir=""
    local config_file=""
    config_dir="$(md_to_pdf_support_config_dir)"
    vendor_dir="$(md_to_pdf_support_vendor_dir)"
    config_file="$config_dir/config.js"

    mkdir -p "$vendor_dir"
    md_to_pdf_support_copy_tree "$mermaid_package_dir" "$vendor_dir/mermaid"
    md_to_pdf_support_copy_tree "$mathjax_package_dir" "$vendor_dir/mathjax"

    local vendor_rel="${vendor_dir#$HOME}"
    write_md_to_pdf_support_config \
        "$config_file" \
        "$vendor_rel/mermaid/$mermaid_relative_path" \
        "$mermaid_mode" \
        "$vendor_rel/mathjax/$mathjax_relative_path"

    echo "✅ md-to-pdf global Mermaid/MathJax support configured at $config_file"
}

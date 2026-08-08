### set
set positional-arguments
set export
set shell := ["bash", "-uc"]



### variable
## info
_gs_init_id := "io.goddaneel.metacubexd"

_gs_init_version_full := ```
'/usr/bin/xmlstarlet' sel -t -v "/component/releases/release/@version" "flatpak/extra/metainfo/io.goddaneel.metacubexd.metainfo.xml"
```

_gs_file_build_flatpak := "sparkle-linux-" + _gs_init_version_full + "-amd64.flatpak"


## path
_gs_path_pwd := invocation_directory()
_gs_path_temp := _gs_path_pwd / "temp"
_gs_path_export := _gs_path_pwd / "export"



### target
default:
        just --list --unsorted


clean-git:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_git"
        #       #
        _la_exec_git=(
                '/usr/bin/git'
                clean -xd -f
        )
        #       #
        "${_la_exec_git[@]}"


clean-rm:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_rm"
        #       #
        _la_exec_rm=(
                '/usr/bin/rm'
                -rfv
                "{{_gs_path_temp}}/flatpak"
        )
        #       #
        "${_la_exec_rm[@]}"


shasum-export arg1:
        #!/bin/bash
        set -euxo pipefail
        #       #
        cd "{{_gs_path_export}}"
        #       #
        declare -a "_la_exec_shasum"
        #       #
        export LC_ALL="C"
        #       #
        _la_exec_shasum=(
                '/usr/bin/shasum'
                -a 512
                {{arg1}}
        )
        #       #
        "${_la_exec_shasum[@]}" >> "{{arg1}}.shasum"


podman-build:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_podman"
        #       #
        _la_exec_podman=(
                '/usr/bin/podman'
                build
                --tag "goddaneel_flatpak-builder"
                "."
        )
        #       #
        "${_la_exec_podman[@]}"
        #       #
        _la_exec_podman=(
                '/usr/bin/podman'
                image
                prune --force
        )
        #       #
        "${_la_exec_podman[@]}"


podman-up:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_podman"
        #       #
        _la_exec_podman=(
                '/usr/bin/podman'
                compose
                --in-pod=false up -d
        )
        #       #
        "${_la_exec_podman[@]}"


podman-down:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_podman"
        #       #
        _la_exec_podman=(
                '/usr/bin/podman'
                compose
                down
        )
        #       #
        "${_la_exec_podman[@]}"


podman-exec arg1:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_podman"
        #       #
        _la_exec_podman=(
                '/usr/bin/podman'
                compose
                exec "metacubexd" "{{arg1}}"
        )
        #       #
        "${_la_exec_podman[@]}"


podman-just arg1:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_podman"
        #       #
        _la_exec_podman=(
                '/usr/bin/podman'
                compose
                exec "metacubexd" "just" "{{arg1}}"
        )
        #       #
        "${_la_exec_podman[@]}"


flatpak-build:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_install"
        declare -a "_la_exec_flatpak"
        #       #
        _la_exec_install=(
                '/usr/bin/install'
                -d -v
                "{{_gs_path_temp}}"
                "{{_gs_path_temp}}/flatpak"
                "{{_gs_path_temp}}/flatpak/repo"
                "{{_gs_path_temp}}/flatpak/state"
                "{{_gs_path_temp}}/flatpak/dir"
        )
        #       #
        "${_la_exec_install[@]}"
        #       #
        _la_exec_flatpak=(
                '/usr/bin/flatpak-builder'
                --force-clean --disable-rofiles-fuse
                --install-deps-from="flathub"
                --repo="{{_gs_path_temp}}/flatpak/repo"
                --state-dir="{{_gs_path_temp}}/flatpak/state"
                "{{_gs_path_temp}}/flatpak/dir"
                "{{_gs_path_pwd}}/flatpak/io.goddaneel.metacubexd.yml"
        )
        #       #
        "${_la_exec_flatpak[@]}"


flatpak-export:
        #!/bin/bash
        set -euxo pipefail
        #       #
        declare -a "_la_exec_install"
        declare -a "_la_exec_flatpak"
        #       #
        _la_exec_install=(
                '/usr/bin/install'
                -d -v
                "{{_gs_path_export}}"
        )
        #       #
        "${_la_exec_install[@]}"
        #       #
        _la_exec_flatpak=(
                '/usr/bin/flatpak'
                build-bundle
                "{{_gs_path_temp}}/flatpak/repo"
                "{{_gs_path_export}}/{{_gs_file_build_flatpak}}"
                "{{_gs_init_id}}"
        )
        #       #
        "${_la_exec_flatpak[@]}"
        #       #
        just shasum-export "{{_gs_file_build_flatpak}}"



work-clean:
        just clean-rm
        just clean-git

work-flatpak:
        just flatpak-build
        just flatpak-export
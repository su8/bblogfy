# 08/29/2024 https://github.com/su8/bblogfy

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

for x in `ls -a markdown`; do {
  if [[ $x == "." || $x == ".." ]]; then
    continue;
  fi
  mkdir -p "generated/${x%.md}";
  pandoc -s -f markdown -t html5 -o "generated/${x%.md}/index.html" -c style.css "markdown/${x}" --metadata title='...';
} done;
echo "Done"


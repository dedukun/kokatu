# kokatu

Kokatu is a POSIX script which works as a wrapper for [fd](https://github.com/sharkdp/fd) and [ripgrep](https://github.com/BurntSushi/ripgrep), 
bringing a similar functionality to mlocate, i.e, it indexes the system files and then allows the user to search in this index.

## Requirements

For the base usage of kokatu, you only need to have [fd](https://github.com/sharkdp/fd) and [ripgrep](https://github.com/BurntSushi/ripgrep) installed.
If you want to use compression, you will need to have [lz4](https://github.com/lz4/lz4) in your system.

## Usage

To create/update the index with kokatu, you just need to run the script with the option `-u`.
It is required to run this as root.

To search for an entry, you need to run the script with the pattern you want to search, `kokatu <pattern>`.

```bash
# Create/Update database
$ sudo kokatu -u

# Search for pattern 'README.md'
$ kokatu README.md
```

## Options

The currently supported options are:

- **-d \<database-path\>**  - It overwrites the default path of the database/index [default: /tmp/kokatu.db]
- **-u**                    - It updates/creates the database
- **-c**                    - Return the number of matches, instead of the matches themselves
- **-i**                    - Ignore case when searching

## Compression

By default, kokatu doesn't compresses the index, however this can be enabled by changing the [following line](https://github.com/dedukun/kokatu/blob/master/kokatu#L9).

```diff
diff --git a/kokatu b/kokatu
--- a/kokatu
+++ b/kokatu
@@ -6,7 +6,7 @@

 kokatu_db="/tmp/kokatu.db"

-compression=""
+compression="Y"
 verbose=""

 rg_options="-z"
```

## Performance
 
## TODO

- Configuration file

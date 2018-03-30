Return-Path: <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
To: Benjamin Coddington <bcodding@redhat.com>, <fstests@vger.kernel.org>
CC: Scott Mayhew <smayhew@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
	<linux-nfs@vger.kernel.org>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <b6d7f60d-a394-1304-cf06-f4fb385dc002@Netapp.com>
Date: Fri, 30 Mar 2018 10:41:43 -0400
MIME-Version: 1.0
In-Reply-To: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

I like this patch!  It's weird to see generic/035 actually pass for a change :)

Anna

On 03/29/2018 11:34 AM, Benjamin Coddington wrote:
> We'd like to run generic tests for NFS, but often have slightly different
> output for our results.  One instance is that for the NFS client the
> removal of an open file or directory is handled differently than for a
> local filesystem.  We can expect nlink to be 1 for files, and to receive
> -ESTALE for operations on deleted directories, isn't that silly?
> 
> Override the default output when FSTYP == "nfs".
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  .gitignore                                 | 1 +
>  tests/generic/035                          | 3 +++
>  tests/generic/035.cfg                      | 1 +
>  tests/generic/{035.out => 035.out.default} | 0
>  tests/generic/035.out.nfs                  | 5 +++++
>  5 files changed, 10 insertions(+)
>  create mode 100644 tests/generic/035.cfg
>  rename tests/generic/{035.out => 035.out.default} (100%)
>  create mode 100644 tests/generic/035.out.nfs
> 
> diff --git a/.gitignore b/.gitignore
> index 368d11c84a66..b2419862aff9 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -246,6 +246,7 @@
>  /tests/xfs/033.out
>  /tests/xfs/071.out
>  /tests/xfs/096.out
> +/tests/generic/035.out
>  
>  # cscope files
>  cscope.*
> diff --git a/tests/generic/035 b/tests/generic/035
> index 443ddd57bfc0..37423f32dddd 100755
> --- a/tests/generic/035
> +++ b/tests/generic/035
> @@ -21,6 +21,7 @@
>  #-----------------------------------------------------------------------
>  #
>  
> +seqfull=$0
>  seq=`basename $0`
>  seqres=$RESULT_DIR/$seq
>  echo "QA output created by $seq"
> @@ -44,6 +45,8 @@ _supported_os Linux
>  
>  _require_test
>  
> +_link_out_file $FSTYP
> +
>  # real QA test starts here
>  
>  rename_dir=$TEST_DIR/$$
> diff --git a/tests/generic/035.cfg b/tests/generic/035.cfg
> new file mode 100644
> index 000000000000..d02b0ce907d4
> --- /dev/null
> +++ b/tests/generic/035.cfg
> @@ -0,0 +1 @@
> +nfs: nfs
> diff --git a/tests/generic/035.out b/tests/generic/035.out.default
> similarity index 100%
> rename from tests/generic/035.out
> rename to tests/generic/035.out.default
> diff --git a/tests/generic/035.out.nfs b/tests/generic/035.out.nfs
> new file mode 100644
> index 000000000000..6359197f1d04
> --- /dev/null
> +++ b/tests/generic/035.out.nfs
> @@ -0,0 +1,5 @@
> +QA output created by 035
> +overwriting regular file:
> +nlink is 1, should be 0
> +overwriting directory:
> +t_rename_overwrite: fstat(3): Stale file handle
> 

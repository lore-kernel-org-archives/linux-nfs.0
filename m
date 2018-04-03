Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f65.google.com ([209.85.160.65]:35580 "EHLO
        mail-pl0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbeDCJDZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2018 05:03:25 -0400
Date: Tue, 3 Apr 2018 17:03:17 +0800
From: Eryu Guan <guaneryu@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: fstests@vger.kernel.org, Scott Mayhew <smayhew@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Message-ID: <20180403090317.GM30836@localhost.localdomain>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2018 at 11:34:39AM -0400, Benjamin Coddington wrote:
> We'd like to run generic tests for NFS, but often have slightly different
> output for our results.  One instance is that for the NFS client the
> removal of an open file or directory is handled differently than for a
> local filesystem.  We can expect nlink to be 1 for files, and to receive
> -ESTALE for operations on deleted directories, isn't that silly?
> 
> Override the default output when FSTYP == "nfs".
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

Thanks for the patch!

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

We usually _link_out_file according to the features enabled at mkfs
time, so linking a .out file based on $FSTYP makes me wonder if it's
really a 'generic' test then.

So I think we could 'edit' the output for NFS a bit, e.g.

-src/t_rename_overwrite $file1 $file2
+# comments about why we special-case nfs here
+src/t_rename_overwrite $file1 $file2 >$tmp.file 2>&1
+if [ "$FSTYP" = "nfs" ]; then
+       sed -i '/nlink is 1/d' $tmp.file
+fi
+cat $tmp.file

Similar 'edit' can be done to the dir case too.

Thanks,
Eryu

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
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

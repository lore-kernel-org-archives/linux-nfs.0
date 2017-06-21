Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48420 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbdFUIhH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Jun 2017 04:37:07 -0400
Date: Wed, 21 Jun 2017 16:37:04 +0800
From: Eryu Guan <eguan@redhat.com>
To: Xiao Yang <yangx.jy@cn.fujitsu.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] generic/294: fix output for nfs
Message-ID: <20170621083704.GD17669@eguan.usersys.redhat.com>
References: <1497951333-5925-1-git-send-email-yangx.jy@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1497951333-5925-1-git-send-email-yangx.jy@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 20, 2017 at 05:35:33PM +0800, Xiao Yang wrote:
> In nfs environment, both mkdir and mknod are optimized and
> return EROFS instead of EEXIST when asking to create an
> already-existing entity on an RO filesystem.  We add specific
> output of nfs to fix it.

This test just exercises this code path, it expects EEXIST instead of
EROFS. Not sure if it's NFS that needs to be fixed, not the test case.
cc linux-nfs list to request for more comments.

Thanks,
Eryu

> 
> Signed-off-by: Xiao Yang <yangx.jy@cn.fujitsu.com>
> ---
>  tests/generic/294             | 3 +++
>  tests/generic/294.cfg         | 1 +
>  tests/generic/294.out         | 5 -----
>  tests/generic/294.out.default | 5 +++++
>  tests/generic/294.out.nfs     | 5 +++++
>  5 files changed, 14 insertions(+), 5 deletions(-)
>  create mode 100644 tests/generic/294.cfg
>  delete mode 100644 tests/generic/294.out
>  create mode 100644 tests/generic/294.out.default
>  create mode 100644 tests/generic/294.out.nfs
> 
> diff --git a/tests/generic/294 b/tests/generic/294
> index fb5d9aa..bc20dad 100755
> --- a/tests/generic/294
> +++ b/tests/generic/294
> @@ -22,6 +22,7 @@
>  #-----------------------------------------------------------------------
>  #
>  
> +seqfull=$0
>  seq=`basename $0`
>  seqres=$RESULT_DIR/$seq
>  echo "QA output created by $seq"
> @@ -48,6 +49,8 @@ _supported_fs generic
>  _supported_os Linux
>  _require_scratch
>  
> +_link_out_file_named $seqfull.out $FSTYP
> +
>  rm -f $seqres.full
>  _scratch_mkfs > $seqres.full 2>&1 || _fail "Could not mkfs scratch device"
>  
> diff --git a/tests/generic/294.cfg b/tests/generic/294.cfg
> new file mode 100644
> index 0000000..d02b0ce
> --- /dev/null
> +++ b/tests/generic/294.cfg
> @@ -0,0 +1 @@
> +nfs: nfs
> diff --git a/tests/generic/294.out b/tests/generic/294.out
> deleted file mode 100644
> index 7802472..0000000
> --- a/tests/generic/294.out
> +++ /dev/null
> @@ -1,5 +0,0 @@
> -QA output created by 294
> -mknod: SCRATCH_MNT/294.test/testnode: File exists
> -mkdir: cannot create directory 'SCRATCH_MNT/294.test/testdir': File exists
> -touch: cannot touch 'SCRATCH_MNT/294.test/testtarget': Read-only file system
> -ln: creating symbolic link 'SCRATCH_MNT/294.test/testlink': File exists
> diff --git a/tests/generic/294.out.default b/tests/generic/294.out.default
> new file mode 100644
> index 0000000..7802472
> --- /dev/null
> +++ b/tests/generic/294.out.default
> @@ -0,0 +1,5 @@
> +QA output created by 294
> +mknod: SCRATCH_MNT/294.test/testnode: File exists
> +mkdir: cannot create directory 'SCRATCH_MNT/294.test/testdir': File exists
> +touch: cannot touch 'SCRATCH_MNT/294.test/testtarget': Read-only file system
> +ln: creating symbolic link 'SCRATCH_MNT/294.test/testlink': File exists
> diff --git a/tests/generic/294.out.nfs b/tests/generic/294.out.nfs
> new file mode 100644
> index 0000000..71ebeec
> --- /dev/null
> +++ b/tests/generic/294.out.nfs
> @@ -0,0 +1,5 @@
> +QA output created by 294
> +mknod: 'SCRATCH_MNT/294.test/testnode': Read-only file system
> +mkdir: cannot create directory 'SCRATCH_MNT/294.test/testdir': Read-only file system
> +touch: cannot touch 'SCRATCH_MNT/294.test/testtarget': Read-only file system
> +ln: creating symbolic link 'SCRATCH_MNT/294.test/testlink': File exists
> -- 
> 1.8.3.1
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36326 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdFOJj3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 05:39:29 -0400
Date: Thu, 15 Jun 2017 10:39:27 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 07/27] VFS: Differentiate mount flags (MS_*) from
 internal superblock flags [ver #5]
Message-ID: <20170615093927.GG31671@ZenIV.linux.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745338248.10897.17175227466711674034.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149745338248.10897.17175227466711674034.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 04:16:22PM +0100, David Howells wrote:

> diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
> index d2fb9c8ed205..e831c115daf9 100644
> --- a/drivers/base/devtmpfs.c
> +++ b/drivers/base/devtmpfs.c
> @@ -355,7 +355,7 @@ int devtmpfs_mount(const char *mntdir)
>  	if (!thread)
>  		return 0;
>  
> -	err = sys_mount("devtmpfs", (char *)mntdir, "devtmpfs", MS_SILENT, NULL);
> +	err = sys_mount("devtmpfs", (char *)mntdir, "devtmpfs", SB_SILENT, NULL);
>  	if (err)
>  		printk(KERN_INFO "devtmpfs: error mounting %i\n", err);
>  	else
> @@ -381,7 +381,7 @@ static int devtmpfsd(void *p)
>  	*err = sys_unshare(CLONE_NEWNS);
>  	if (*err)
>  		goto out;
> -	*err = sys_mount("devtmpfs", "/", "devtmpfs", MS_SILENT, options);
> +	*err = sys_mount("devtmpfs", "/", "devtmpfs", SB_SILENT, options);

Er...  These really should be MS_SILENT.

> @@ -311,14 +311,14 @@ static void get_dpms_capabilities(unsigned char flags,
>  				  struct fb_monspecs *specs)
>  {
>  	specs->dpms = 0;
> -	if (flags & DPMS_ACTIVE_OFF)
> -		specs->dpms |= FB_DPMS_ACTIVE_OFF;
> +	if (flags & DPSB_ACTIVE_OFF)
> +		specs->dpms |= FB_DPSB_ACTIVE_OFF;

... the hell?

> -	if (sb->s_flags & MS_RDONLY)
> +	if (sb->s_flags & SB_RDONLY)

TBH, it looks like something along the lines of sb_rdonly(sb) for the above would
make more sense.

>  static int flags_to_propagation_type(int flags)
>  {
> -	int type = flags & ~(MS_REC | MS_SILENT);
> +	int type = flags & ~(MS_REC | SB_SILENT);

Huh?

> -	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE | MS_BORN |
> -		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME| MS_KERNMOUNT |
> -		   MS_STRICTATIME | MS_NOREMOTELOCK | MS_SUBMOUNT);
> +	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | SB_ACTIVE | SB_BORN |
> +		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME| SB_KERNMOUNT |
> +		   MS_STRICTATIME | SB_NOREMOTELOCK | SB_SUBMOUNT);

This is complete bullshit.  _IF_ you want to separate these sets, do that
consistently.  Mixing MS_... with SB_... in a mask is obviously wrong.
Sure, you can use the fact that such-and-such SB_ flag is the same value
as MS_... one; worth a BUILD_BUG_ON() somewhere to enforce that.  However,
please separate the places where you have mount(2) flags argument from
those where you have a set of SB_... bits.

In this case you certainly have MS_... bunch.  What's more, I would rather
do it as "we look only at..." instead of "we ignore the following..." - and
probably do it in do_...() functions instead.  Note that they already
have parsing and validation of their own...

> diff --git a/tools/testing/selftests/mount/unprivileged-remount-test.c b/tools/testing/selftests/mount/unprivileged-remount-test.c
> index 517785052f1c..65489157f8d7 100644
> --- a/tools/testing/selftests/mount/unprivileged-remount-test.c
> +++ b/tools/testing/selftests/mount/unprivileged-remount-test.c
> @@ -129,7 +129,7 @@ static int read_mnt_flags(const char *path)
>  	}
>  	mnt_flags = 0;
>  	if (stat.f_flag & ST_RDONLY)
> -		mnt_flags |= MS_RDONLY;
> +		mnt_flags |= SB_RDONLY;
>  	if (stat.f_flag & ST_NOSUID)
>  		mnt_flags |= MS_NOSUID;
>  	if (stat.f_flag & ST_NODEV)
> @@ -143,7 +143,7 @@ static int read_mnt_flags(const char *path)
>  	if (stat.f_flag & ST_RELATIME)
>  		mnt_flags |= MS_RELATIME;
>  	if (stat.f_flag & ST_SYNCHRONOUS)
> -		mnt_flags |= MS_SYNCHRONOUS;
> +		mnt_flags |= SB_SYNCHRONOUS;
>  	if (stat.f_flag & ST_MANDLOCK)
>  		mnt_flags |= ST_MANDLOCK;

Really?  That's userland code, isn't it?

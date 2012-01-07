Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:35818 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab2AGQ5y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2012 11:57:54 -0500
Subject: Re: [PATCH] nfs: Don't try mounting device as nfs root unless type fully matches
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1325927523-30103-1-git-send-email-levinsasha928@gmail.com>
Date: Sat, 7 Jan 2012 11:57:42 -0500
Cc: linux@razik.name, Trond.Myklebust@netapp.com, penberg@kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <5FF522E0-132E-4A6A-A40F-5CCD08AF800A@oracle.com>
References: <1325927523-30103-1-git-send-email-levinsasha928@gmail.com>
To: Sasha Levin <levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Jan 7, 2012, at 4:12 AM, Sasha Levin wrote:

> Currently, we'll try mounting any device who's major device number is
> UNNAMED_MAJOR as NFS root. This would happen for non-NFS devices as well (such
> as 9p devices) but it wouldn't cause any issues since mounting the device
> as NFS would fail quickly and the code proceeded to doing the proper mount:
> 
> 	[  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
> 	[  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
> 
> Commit 6829a048 ("NFS: Retry mounting NFSROOT") has introduced retries when
> mounting NFS root, which means that now we don't immediately fail and instead
> it takes an additional 90+ seconds until we stop retrying.
> 
> This meant that it would take an additional 90 seconds to boot when we're not
> using a device type which gets detected in order before NFS.

The long timeouts are kind of irrelevant, in my view.  The real problem is that NFS was tried at all in this case.  That behavior was not introduced by 6829a058.

> This patch modifies the NFS type check to require device type to be
> 'Root_NFS' instead of requiring the device to have an UNNAMED_MAJOR major.
> This makes boot process cleaner since we now won't go through the NFS mounting
> code at all when the device isn't an NFS root ("/dev/nfs").

Agreed.  I like this approach.

> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
> init/do_mounts.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index 06225d2..da76f2c 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -475,7 +475,7 @@ void __init change_floppy(char *fmt, ...)
> void __init mount_root(void)
> {
> #ifdef CONFIG_ROOT_NFS
> -	if (MAJOR(ROOT_DEV) == UNNAMED_MAJOR) {
> +	if (ROOT_DEV == Root_NFS) {
> 		if (mount_nfs_root())
> 			return;
> 
> -- 
> 1.7.8.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





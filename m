Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38120 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580Ab2EGI6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 04:58:14 -0400
Date: Mon, 7 May 2012 10:58:09 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, chuck.lever@oracle.com, linux@razik.name,
        Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu
Subject: Re: [PATCH] init: don't try mounting device as nfs root unless type
 fully matches
Message-ID: <20120507085809.GA23002@gmail.com>
References: <1336230395-5215-1-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336230395-5215-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Sasha Levin <levinsasha928@gmail.com> wrote:

> Currently, we'll try mounting any device who's major device number is
> UNNAMED_MAJOR as NFS root. This would happen for non-NFS devices as well (such
> as 9p devices) but it wouldn't cause any issues since mounting the device
> as NFS would fail quickly and the code proceeded to doing the proper mount:
> 
>        [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
>        [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
> 
> Commit 6829a048 ("NFS: Retry mounting NFSROOT") has introduced retries when
> mounting NFS root, which means that now we don't immediately fail and instead
> it takes an additional 90+ seconds until we stop retrying, which has revealed
> the issue this patch fixes.
> 
> This meant that it would take an additional 90 seconds to boot when we're not
> using a device type which gets detected in order before NFS.
> 
> This patch modifies the NFS type check to require device type to be
> 'Root_NFS' instead of requiring the device to have an UNNAMED_MAJOR major.
> This makes boot process cleaner since we now won't go through the NFS mounting
> code at all when the device isn't an NFS root ("/dev/nfs").
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  init/do_mounts.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index 8dfa0de..d3f0aee 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -482,7 +482,7 @@ void __init change_floppy(char *fmt, ...)
>  void __init mount_root(void)
>  {
>  #ifdef CONFIG_ROOT_NFS
> -	if (MAJOR(ROOT_DEV) == UNNAMED_MAJOR) {
> +	if (ROOT_DEV == Root_NFS) {
>  		if (mount_nfs_root())
>  			return;

Acked-by: Ingo Molnar <mingo@elte.hu>

This bug actively broke my KVM bootup, it gave the impression 
that the bootup was hung, while it was just retrying for a 
looong time.

Thanks,

	Ingo

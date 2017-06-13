Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37584 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751965AbdFMMk2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 08:40:28 -0400
Subject: Re: [nfs-utils PATCH] umount.nfs: assume path name is canonical.
To: NeilBrown <neilb@suse.com>, util-linux@vger.kernel.org,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Franck Bui <fbui@suse.com>
References: <8760gbduzp.fsf@notabene.neil.brown.name>
 <8737bfduq8.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <fddad636-4a27-dd44-1b7f-edfb81005049@RedHat.com>
Date: Tue, 13 Jun 2017 08:40:26 -0400
MIME-Version: 1.0
In-Reply-To: <8737bfduq8.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/04/2017 10:38 PM, NeilBrown wrote:
> 
> /usr/bin/umount will always pass a canonical name
> to umount.nfs, so it is safe to disable canonicalization.
> 
> When umounting an NFS filesystem, it is generally safest to
> not "stat" the mountpoint at all as that can block
> indefinitely.  umount() will not block, but lstat() etc can.
> By disabling canonicalization in libmount, we discourage it
> from ever calling 'stat' family operations, and thus reduce
> the chance of a hang.
> 
> Note that to be fully effective, this requires changes to
> util-linux which have not yet been accepted.
> When both that change and this are in effect, automounters
> can use "umount -c $PATH" to safely unmount a filesystem
> without blocking.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... 

steved.

> ---
>  utils/mount/mount_libmount.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index 1f01f7f7a4e7..2d4065759a6c 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -188,6 +188,7 @@ static int umount_main(struct libmnt_context *cxt, int argc, char **argv)
>  	};
>  
>  	mnt_context_init_helper(cxt, MNT_ACT_UMOUNT, 0);
> +	mnt_context_disable_canonicalize(cxt, 1);
>  
>  	while ((c = getopt_long (argc, argv, "fvnrlh", longopts, NULL)) != -1) {
>  
> 

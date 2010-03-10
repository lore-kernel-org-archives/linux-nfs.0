From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Possible-Patch: unregister bdi on error path.
Date: Wed, 10 Mar 2010 18:01:47 -0500
Message-ID: <1268262107.3096.207.camel@localhost.localdomain>
References: <19352.6543.377883.277948@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39497 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757385Ab0CJXBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Mar 2010 18:01:52 -0500
In-Reply-To: <19352.6543.377883.277948-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-03-11 at 09:13 +1100, Neil Brown wrote: 
> 
> Hi,
>  I've had an internal report of the following error:
> 
> 
> [145405.949506] WARNING: at /usr/src/packages/BUILD/kernel-default-2.6.32.8/linux-2.6.32/fs/sysfs/dir.c:491 sysfs_add_one+0xf4/0x120()
> [145405.949516] sysfs: cannot create duplicate filename '/devices/virtual/bdi/0:26'
> ...
> [145405.949598] Pid: 8745, comm: mount.nfs Not tainted 2.6.32.8-0.3-default #1
> [145405.949601] Call Trace:
> ...
> [145405.949644]  [<ffffffff811877c4>] sysfs_add_one+0xf4/0x120
> [145405.949650]  [<ffffffff811883c0>] create_dir+0x60/0xb0
> [145405.949656]  [<ffffffff81188441>] sysfs_create_dir+0x31/0x50
> [145405.949663]  [<ffffffff8120a8ef>] kobject_add_internal+0xff/0x260
> [145405.949669]  [<ffffffff8120ac56>] kobject_add+0x46/0x70
> [145405.949675]  [<ffffffff812c06b6>] device_add+0xc6/0x4e0
> [145405.949682]  [<ffffffff812c0c2f>] device_create_vargs+0x13f/0x150
> [145405.949689]  [<ffffffff810eceea>] bdi_register+0x7a/0x180
> [145405.949707]  [<ffffffffa04fb006>] nfs_get_sb+0x316/0x430 [nfs]
> [145405.949735]  [<ffffffff8112195d>] vfs_kern_mount+0x7d/0x1b0
> [145405.949741]  [<ffffffff81121af3>] do_kern_mount+0x53/0x120
> [145405.949748]  [<ffffffff8113b7dc>] do_mount+0x21c/0x250
> [145405.949754]  [<ffffffff8113b8d0>] sys_mount+0xc0/0xf0
> 
> 
> i.e. it tried to bdi_register 0:26 while it was already registered.
> 
> Looking through the code, it seems that if nfs_get_sb calls
> nfs_bdi_register, but then doesn't set ->s_root, then ->put_super
> is not called (generic_shutdown_super only calls ->put_super if s_root
> is set), so the bdi is never unregistered.  The next mount
> would then trigger the above error.
> 
> I haven't found a way to trigger this situation, but it seems like it
> should be possible.
> 
> Does this patch make sense?
> 
> Thanks,
> NeilBrown
> 
> ----------------------------
> NFS: ensure bdi_unregister is called on mount failure.
> 
> bdi_unregister is called by nfs_put_super which is only called by
> generic_shutdown_super if ->s_root is not NULL.  So if we error out
> in a circumstance where we called nfs_bdi_register (i.e. server !=
> NULL) but have not set s_root, then we need to call bdi_unregister
> explicitly in nfs_get_sb.
> 
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index f1afee4..da11ec9 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2214,7 +2214,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
>  	} else {
>  		error = nfs_bdi_register(server);
>  		if (error)
> -			goto error_splat_super;
> +			goto error_splat_bdi;
>  	}
>  
>  	if (!s->s_root) {
> @@ -2256,6 +2256,9 @@ out_err_nosb:
>  error_splat_root:
>  	dput(mntroot);
>  error_splat_super:
> +	if (server && !s->s_root)
> +		bdi_unregister(&server->backing_dev_info);
> +error_splat_bdi:
>  	deactivate_locked_super(s);
>  	goto out;
>  }

Yes. It looks as if you have indeed found a bug.

My main comment is that in order to be complete the patch should also
address the cases of nfs_xdev_get_sb(), nfs4_remote_get_sb(),
nfs4_xdev_get_sb(), and nfs4_remote_referral_get_sb(). They appear to
suffer from the same problem...

Cheers
  Trond


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:49177 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab1CVW6d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 18:58:33 -0400
Subject: Re: [PATCH] nfs4: Fix NULL dereference at d_alloc_and_lookup()
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1300830742.9442.53.camel@lade.trondhjem.org>
References: <1300830025-17152-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1300830742.9442.53.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 01:58:27 +0300
Message-ID: <1300834707.17103.61.camel@vT510>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-22 at 17:52 -0400, Trond Myklebust wrote:
> On Wed, 2011-03-23 at 00:40 +0300, Vitaliy Gusev wrote:
> > From: Gusev Vitaliy <gusev.vitaliy@nexenta.com>
> > 
> > d_alloc_and_lookup() calls i_op->lookup method due to
> > rootfh changes his fsid.
> >
> > During mount i_op of NFS root inode is set to
> > nfs_mountpoint_inode_operations, if rpc_ops->getroot()
> > and rpc_ops->getattr() return different fsid.
> 
> That is a server bug! Why are you trying to "fix" that on the client
> instead of telling the user that their server deserves to be burned
> behind the shed?
> 

Because nfs_update_inode() does it with success and pleasure:

	if (S_ISDIR(inode->i_mode) && (fattr->valid & NFS_ATTR_FATTR_FSID) &&
			!nfs_fsid_equal(&server->fsid, &fattr->fsid) &&
			!IS_AUTOMOUNT(inode))
		server->fsid = fattr->fsid;

And what are the reasons to tell to user about broken servers during
mount, but do not tell about it after mount ?


> >  
> > +	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
> > +	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
> > +		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
> 
> No. add a printk() to the effect that the server is insane, return -EIO
> and we're done...

Ok. Next checks mntroot->d_inode->i_op != dir_inode_ops) from super.c
does what you pointed. But it is only for cross mounts and referrals.


	mntroot = nfs4_get_root(s, mntfh);
	if (IS_ERR(mntroot)) {
		error = PTR_ERR(mntroot);
		goto error_splat_super;
	}

	if (mntroot->d_inode->i_op !=
NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
		dput(mntroot);
		error = -ESTALE;
		goto error_splat_super;
	}




-- 
Thanks,
Vitaliy Gusev


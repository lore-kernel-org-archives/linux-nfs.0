Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59375 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932353Ab1CVVwY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 17:52:24 -0400
Subject: Re: [PATCH] nfs4: Fix NULL dereference at d_alloc_and_lookup()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1300830025-17152-1-git-send-email-gusev.vitaliy@nexenta.com>
References: <1300830025-17152-1-git-send-email-gusev.vitaliy@nexenta.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Mar 2011 17:52:22 -0400
Message-ID: <1300830742.9442.53.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 00:40 +0300, Vitaliy Gusev wrote:
> From: Gusev Vitaliy <gusev.vitaliy@nexenta.com>
> 
> d_alloc_and_lookup() calls i_op->lookup method due to
> rootfh changes his fsid.
>
> During mount i_op of NFS root inode is set to
> nfs_mountpoint_inode_operations, if rpc_ops->getroot()
> and rpc_ops->getattr() return different fsid.

That is a server bug! Why are you trying to "fix" that on the client
instead of telling the user that their server deserves to be burned
behind the shed?

>  
> +	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
> +	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
> +		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));

No. add a printk() to the effect that the server is insane, return -EIO
and we're done...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


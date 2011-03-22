Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2697 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755125Ab1CVX76 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 19:59:58 -0400
Subject: Re: [PATCH] nfs4: Fix NULL dereference at d_alloc_and_lookup()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1300834707.17103.61.camel@vT510>
References: <1300830025-17152-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1300830742.9442.53.camel@lade.trondhjem.org>
	 <1300834707.17103.61.camel@vT510>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Mar 2011 19:59:39 -0400
Message-ID: <1300838379.22796.35.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 01:58 +0300, Vitaliy Gusev wrote:
> On Tue, 2011-03-22 at 17:52 -0400, Trond Myklebust wrote:
> > On Wed, 2011-03-23 at 00:40 +0300, Vitaliy Gusev wrote:
> > > From: Gusev Vitaliy <gusev.vitaliy@nexenta.com>
> > > 
> > > d_alloc_and_lookup() calls i_op->lookup method due to
> > > rootfh changes his fsid.
> > >
> > > During mount i_op of NFS root inode is set to
> > > nfs_mountpoint_inode_operations, if rpc_ops->getroot()
> > > and rpc_ops->getattr() return different fsid.
> > 
> > That is a server bug! Why are you trying to "fix" that on the client
> > instead of telling the user that their server deserves to be burned
> > behind the shed?
> > 
> 
> Because nfs_update_inode() does it with success and pleasure:
> 
> 	if (S_ISDIR(inode->i_mode) && (fattr->valid & NFS_ATTR_FATTR_FSID) &&
> 			!nfs_fsid_equal(&server->fsid, &fattr->fsid) &&
> 			!IS_AUTOMOUNT(inode))
> 		server->fsid = fattr->fsid;
> 
> And what are the reasons to tell to user about broken servers during
> mount, but do not tell about it after mount ?

Sigh... That is a valid point.

Looking at the Linux NFS server, I see that it has 3 different ways to
derive a fsid: only two are guaranteed to survive a reboot. I believe
that is probably why we added the above code to nfs_update_inode().

Looking now at the uses of nfs4_get_root(), it looks as if all the users
have compared the original fsid to the super block fsid prior to getting
here, and so we know (hope) that the directory that was obtained with
this filehandle did at one point match. If that is always the case, then
we should be safe w.r.t. mistaking this for a server-side mountpoint.
Since a referral is supposed to give us an error when we try to get the
directory attributes, then we know this isn't pointing to a referral.

OK, I'll take this patch...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


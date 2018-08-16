Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34538 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726334AbeHPUyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Aug 2018 16:54:46 -0400
Date: Thu, 16 Aug 2018 13:54:52 -0400
From: Bruce Fields <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
Message-ID: <20180816175452.GA4649@fieldses.org>
References: <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com>
 <874lg3roua.fsf@notabene.neil.brown.name>
 <20180810170027.GF7906@fieldses.org>
 <20180810170312.GG7906@fieldses.org>
 <87d0uor11r.fsf@notabene.neil.brown.name>
 <20180812132100.GL7906@fieldses.org>
 <878t5bqgx0.fsf@notabene.neil.brown.name>
 <87ftzhb9rh.fsf@notabene.neil.brown.name>
 <20180814194334.GO7906@fieldses.org>
 <87r2iz9mbc.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87r2iz9mbc.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 16, 2018 at 10:39:35AM +1000, NeilBrown wrote:
> On Tue, Aug 14 2018, Bruce Fields wrote:
> > Honestly I'm not completely sure I understand the proposal.
> 
> Ok, here is a concrete RFC proposal which should make it easier to
> understand.
> I've tested that this fixes the specific problem in that a user with a
> uid that doesn't match the file, but which the server will give
> ownership rights to, can now setacl a file.

Thanks, this makes sense to me.

I might try to split this change into a couple steps, but I'm not sure
exactly how.

Minor nits:

> From 34f8b23b224e575d5f1fa30834b247e82a854546 Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.com>
> Date: Thu, 16 Aug 2018 10:37:21 +1000
> Subject: [PATCH] VFS: introduce MAY_ACT_AS_OWNER
> 
> A few places in VFS, particularly set_posix_acl(), use
> inode_owner_or_capable() to check if the caller has "owner"
> access to the inode.
> This assumes that it is valid to test inode->i_uid, which is not
> always the case.  Particularly in the case of NFS it is not valid to
> us i_uid (or i_mode) for permission tests - the server needs to make
> the decision.
> 
> As a result if the server is remaping uids

remapping

> (e.g. all-squash,anon_uid=1000),
> then all users should have ownership access, but most users will not
> be able to set acls.
> 
> This patch moves the ownership test to inode_permission and
> i_op->permission.
> A new flag for this functions, MAY_ACT_AS_OWNER is introduced.

these functions?

> generic_permission() now handles this correctly and many
> i_op->permission functions call this function() and don't need any
> changes.  A few are changed to handle MAY_ACT_AS_OWNER exactly
> as generic_permission() does, using inode_owner_or_capable().
> For these filesystems, no behavioural change should be noticed.
> 
> For NFS, nfs_permission is changed to always return 0 (success) if
> MAY_ACT_AS_OWNER.  For NFS, and operations which use this flag should

any operations

> @@ -2038,12 +2038,13 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
>  	 * We must trust the client to do permission checking - using "ACCESS"
>  	 * with NFSv3.
>  	 */
> -	if ((acc & NFSD_MAY_OWNER_OVERRIDE) &&
> -	    uid_eq(inode->i_uid, current_fsuid()))
> -		return 0;
>  
>  	/* This assumes  NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC} */

Can we do the same for NFSD_MAY_OWNER_OVERRIDE and drop the extra "if"
statement?

> -	err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
> +	if (acc & NFSD_MAY_OWNER_OVERRIDE)
> +		err = inode_permission(inode, ((acc & (MAY_READ|MAY_WRITE|MAY_EXEC))
> +					       | MAY_ACT_AS_OWNER));
> +	else
> +		err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
>  
>  	/* Allow read access to binaries even when mode 111 */
>  	if (err == -EACCES && S_ISREG(inode->i_mode) &&

--b.

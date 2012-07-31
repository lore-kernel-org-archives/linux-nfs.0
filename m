Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754371Ab2GaVi7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 17:38:59 -0400
Message-ID: <1343768659.4288.8.camel@localhost>
Subject: Re: [PATCH] Fix array overflow in __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 31 Jul 2012 22:04:19 +0100
In-Reply-To: <1343685259.28035.2.camel@lade.trondhjem.org>
References: <1343129785-4538-1-git-send-email-sprabhu@redhat.com>
	 <1343685259.28035.2.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-07-30 at 21:54 +0000, Myklebust, Trond wrote:
> On Tue, 2012-07-24 at 12:36 +0100, Sachin Prabhu wrote:
> > This fixes a bug introduced by commit
> > 5a00689930ab975fdd1b37b034475017e460cf2a
> > 
> > Bruce Fields pointed out that the changes introduced by the patch will
> > cause the array npages to overflow if a size requested is >=
> > XATTR_SIZE_MAX.
> > 
> > The patch also fixes the check for the length of the ACL returned. The
> > flag ACL_LEN_REQUEST has been renamed to NFS4_ACL_LEN_ONLY and apart
> > from indicating that the user is just interested in the ACL length when
> > making a request, it is also used to indicate if the xdr pages buffer
> > returned in response holds the complete ACL or just the length.
> > 
> > Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
> 
> If this fix is going into stable, then the patch needs to be split up.
> The rename of ACL_LEN_REQUEST to NFS4_ACL_LEN_ONLY is a cleanup and
> should not be propagated to stable...

Trond the change there was required to fix a mistake in the if
condition.

static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf,
size_t buflen)
{
..
        acl_len = res.acl_len - res.acl_data_offset;
        if (acl_len > args.acl_len)
..
}

At this point, 
res.acl_data_offset = size of bitmap array + size of length attribute
res.acl_length = res.acl_data_offset + ACL length 
These 2 variables are set in decode_getacl(). The right check here would
have been to compare res.acl_len and args.acl_len. 

Instead of simply replacing the if condition, I decided to clean up the
code to use NFS4_ACL_LEN_ONLY on advice of Bruce to make the code easier
to understand.

So both parts of this patch are actually bug fixes. If you still think
that they should be separated, I am happy to do that.

Sachin Prabhu


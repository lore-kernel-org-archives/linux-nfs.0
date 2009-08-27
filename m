From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATHC] nfsd: Fix a couple issues with POSIX->NFSv4 ACL
	conversion
Date: Thu, 27 Aug 2009 10:40:11 -0700
Message-ID: <1251394811.32255.6.camel@dyn9047022153>
References: <1250287351.32255.3.camel@dyn9047022153>
	 <20090824235944.GH8532@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:58178 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbZH0Rk1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Aug 2009 13:40:27 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7RHYKEq031568
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2009 13:34:20 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7RHeS2H219592
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2009 13:40:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7RHeSSo000543
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2009 13:40:28 -0400
In-Reply-To: <20090824235944.GH8532@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-24 at 19:59 -0400, J. Bruce Fields wrote:
> On Fri, Aug 14, 2009 at 03:02:30PM -0700, Frank Filz wrote:
> > 1. GROUP@ Allow entry doesn't have NFS4_ACE_IDENTIFIER_GROUP, This
> > appears to have been introduced by accident as part of commit
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=bec50c47aaf6f1f9247f1860547ab394a0802a4c
> 
> It's good to flip that bit every now and then just to keep client
> implementations on their toes....
> 
> 	(Slightly more seriously, the 4.1 draft says "The
> 	ACE4_IDENTIFIER_GROUP flag MUST be ignored on entries with these
> 	special identifiers.  When encoding entries with these special
> 	identifiers, the ACE4_IDENTIFIER_GROUP flag SHOULD be set to
> 	zero."  It really shouldn't matter either way, but the point is
> 	that this flag is used to distinguish named users from named
> 	groups (since unix allows a group to have the same name as a
> 	user), so it doesn't really make sense to use it on a special
> 	identifier such as this.)

Ok, that makes sense, in that case, we probably should have this
fragment to remove the flag from the GROUP@ deny entry:

@@ -321,7 +321,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
 	deny = ~pas.group & pas.other;
 	if (deny) {
 		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
-		ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
+		ace->flag = eflag;
 		ace->access_mask = deny_mask_from_posix(deny, flags);
 		ace->whotype = NFS4_ACL_WHO_GROUP;
 		ace++;



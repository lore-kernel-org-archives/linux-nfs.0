From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] nfsd bug: create file with specific uid/gid
Date: Fri, 30 Nov 2007 17:01:27 -0500
Message-ID: <20071130220127.GJ24887@fieldses.org>
References: <475042FB.8020106@filmlight.ltd.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Roger Willcocks <roger-nMHR1cC4sak0YOejwGmHqw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IyDvL-0001dy-OG
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 14:01:27 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IyDvP-0002tK-Hb
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 14:01:33 -0800
In-Reply-To: <475042FB.8020106-nMHR1cC4sak0YOejwGmHqw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Nov 30, 2007 at 05:06:03PM +0000, Roger Willcocks wrote:
> nfsd/vfs.c:nfsd_create (the v2 version of create) says:
>
> "Set file attributes. Mode has already been set and
> setting uid/gid works only for root"
>
> but it doesn't actually test for root-ness (which could happen if the 
> access is no-root-squash). There's similar code without the comment in 
> nfsd_create_v3. In both cases the test:
>
>    if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0)
>
> should read:
>
>    if (current->fsuid != 0)
>        iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
>    if ((iap->ia_valid &= ~ATTR_MODE) != 0)
>
> although arguably they should return an EPERM error if the uid/gid bits are 
> set, instead of silently ignoring them.

Assignments (especially with things like &=) inside of conditionals
always make my head hurt for some reason.  So maybe something like the
below?

Although I'd be happier if we could get a comment from someone with a
better understanding of why this hack was added in the first place.

Thanks for the bug report!  (And, by the way, how did you run across
this?)

--b.


commit 38574420b8992d69f469ca86041f75b6e2283174
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Nov 30 16:55:23 2007 -0500

    nfsd: allow root to set uid and gid on create
    
    The server silently ignores attempts to set the uid and gid on create.
    Based on the comment, this appears to have been done to prevent some
    overly-clever IRIX client from causing itself problems.
    
    Perhaps we should remove that hack completely.  For now, at least, it
    makes sense to allow root (when no_root_squash is set) to set uid and
    gid.
    
    Thanks to Roger Willcocks <roger-nMHR1cC4sak0YOejwGmHqw@public.gmane.org> for the bug report
    and original patch on which this is based.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 755ba43..8a8bf06 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1257,12 +1257,16 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 
-	/* Set file attributes. Mode has already been set and
-	 * setting uid/gid works only for root. Irix appears to
+	/* Mode has already been set: */
+	iap->ia_valid &= ~ATTR_MODE;
+	/*
+	 * Setting uid/gid works only for root.  Irix appears to
 	 * send along the gid when it tries to implement setgid
-	 * directories via NFS.
+	 * directories via NFS:
 	 */
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0) {
+	if (current->fsuid != 0)
+		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
+	if (iap->ia_valid) {
 		__be32 err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
 		if (err2)
 			err = err2;

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


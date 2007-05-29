From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: fix uninitialized variable
Date: Tue, 29 May 2007 15:52:27 -0400
Message-ID: <20070529195227.GG6815@fieldses.org>
References: <20070527103442.GA10594@havoc.gtf.org>
	<20070529030050.GB20631@fieldses.org> <465B9BB9.7060300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ht7kA-0006CU-3A
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 12:52:34 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ht7kA-0006TV-Sz
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 12:52:37 -0700
In-Reply-To: <465B9BB9.7060300@garzik.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, May 28, 2007 at 11:19:21PM -0400, Jeff Garzik wrote:
> J. Bruce Fields wrote:
> >But I don't want anyone else wasting their time on this.  Should we cave
> >in and add the initialization here just to shut up gcc?  Or would a
> >comment here help?
> 
> Given what you said above, I don't see gcc, on its best day, will ever 
> know enough to validate that that variable is indeed always initialized. 

I recall there being arguments before about when to add initializations.
Unfortunately I can't remember the content of those arguments.  But I
thought that on the gcc-haters side the complaint was exactly that gcc
was emitting warnings in cases where it could never hope to determine
whether an initialization is required.  Am I misremembering?

>  So I would vote for silencing it on those grounds.

That said, I'm OK with the extra initialization.  Might be worth a
comment, though, just to avoid giving the wrong impression about the
assumptions here; something like:

--b.

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index cc3b7ba..4adb5ee 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -183,8 +183,13 @@ static void
 summarize_posix_acl(struct posix_acl *acl, struct posix_acl_summary *pas)
 {
 	struct posix_acl_entry *pa, *pe;
-	pas->users = 0;
-	pas->groups = 0;
+
+	/*
+	 * Only pas.users and pas.groups need initialization; previous
+	 * posix_acl_valid() calls ensure that the other fields will be
+	 * initialized in the following loop.  But, just to placate gcc:
+	 */
+	memset(pas, 0, sizeof(*pas));
 	pas->mask = 07;
 
 	pe = acl->a_entries + acl->a_count;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

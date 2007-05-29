From: "young dave" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH] NFSD: fix uninitialized variable
Date: Tue, 29 May 2007 08:32:42 +0000
Message-ID: <a8e1da0705290132l328f1e4t10d2c0495d46f5fe@mail.gmail.com>
References: <20070527103442.GA10594@havoc.gtf.org>
	<20070529030050.GB20631@fieldses.org> <465B9BB9.7060300@garzik.org>
	<a8e1da0705282131w72fbed65g8cb28589202298c1@mail.gmail.com>
	<465BD64A.3040302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jeff Garzik <jeff@garzik.org>, neilb@suse.de,
	LKML <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>
To: "Matt Keenan" <tank.en.mate@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hsx8D-00016R-Ea
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 01:32:41 -0700
Received: from an-out-0708.google.com ([209.85.132.249])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hsx8F-0001cO-An
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 01:32:44 -0700
Received: by an-out-0708.google.com with SMTP id b38so528595ana
	for <nfs@lists.sourceforge.net>; Tue, 29 May 2007 01:32:42 -0700 (PDT)
In-Reply-To: <465BD64A.3040302@gmail.com>
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

Hi, matt
embarrassed :)
below resend it.

diff -dur linux/fs/nfsd/nfs4acl.c linux.new/fs/nfsd/nfs4acl.c
--- linux/fs/nfsd/nfs4acl.c     2007-05-29 12:28:29.000000000 +0000
+++ linux.new/fs/nfsd/nfs4acl.c 2007-05-29 16:32:26.000000000 +0000
@@ -183,8 +183,6 @@
 summarize_posix_acl(struct posix_acl *acl, struct posix_acl_summary *pas)
 {
        struct posix_acl_entry *pa, *pe;
-       pas->users = 0;
-       pas->groups = 0;
        pas->mask = 07;

        pe = acl->a_entries + acl->a_count;
@@ -229,6 +227,7 @@
        int eflag = ((flags & NFS4_ACL_TYPE_DEFAULT) ?
                NFS4_INHERITANCE_FLAGS | NFS4_ACE_INHERIT_ONLY_ACE : 0);

+       memset(pas, 0, sizeof(struct posix_acl_summary));
        BUG_ON(pacl->a_count < 3);
        summarize_posix_acl(pacl, &pas);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 8] knfsd: nfsd4: silence a compiler warning in
	ACL code
Date: Thu, 21 Jun 2007 14:30:45 +1000
Message-ID: <1070621043045.1081@suse.de>
References: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EJs-0005m1-8H
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:30:56 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EJu-0008JZ-5A
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:30:59 -0700
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


From: "J. Bruce Fields" <bfields@fieldses.org>


Silence a compiler warning in the ACL code, and add a comment making
clear the initialization serves no other purpose.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-06-21 13:46:39.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2007-06-21 14:10:06.000000000 +1000
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

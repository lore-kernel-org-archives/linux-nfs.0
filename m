From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1 of 3] nfsd4: fix fs locations bounds-checking
Date: Mon, 2 Oct 2006 14:24:51 -0400
Message-ID: <20061002182451.GC8084@fieldses.org>
References: <20060929130518.23919.patches@notabene>
	<1060929030913.24108@suse.de>
	<20060928234540.fd74f1e1.akpm@osdl.org>
	<20061002182327.GB8084@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUSTF-0006HP-QR
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 11:24:53 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GUSTG-00083O-CX
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 11:24:54 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061002182327.GB8084@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


The comparison here is obviously useless as locations_count is unsigned.

Though fsloc_parse can only be handed data by root, still I'd rather have
some sanity-checking; so set a (generous) maximum number of fslocations to
keep the following kzalloc to a reasonable size.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c            |    2 +-
 include/linux/nfsd/export.h |    3 +++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 7e429ca..71f3655 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -418,7 +418,7 @@ fsloc_parse(char **mesg, char *buf, stru
 	err = get_int(mesg, &fsloc->locations_count);
 	if (err)
 		return err;
-	if (fsloc->locations_count < 0)
+	if (fsloc->locations_count > MAX_FS_LOCATIONS)
 		return -EINVAL;
 	if (fsloc->locations_count == 0)
 		return 0;
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 101fb4c..6e78ea9 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -48,6 +48,9 @@ #ifdef __KERNEL__
 /*
  * FS Locations
  */
+
+#define MAX_FS_LOCATIONS	128
+
 struct nfsd4_fs_location {
 	char *hosts; /* colon separated list of hosts */
 	char *path;  /* slash separated list of path components */
-- 
1.4.2.g55c3


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

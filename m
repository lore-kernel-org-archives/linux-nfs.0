From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 3/5] nfsstat: fix a bug in diff_stats()
Date: Tue, 7 Aug 2007 19:53:00 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071947570.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYrB-0006K2-PZ
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:57 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYrF-0005w3-Fv
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:53:01 -0700
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

	Fix a bug in diff_stats() that causes false-positives in 
has_stats(), which can result in a bunch of zeros being displayed instead 
of suppressed as intended.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 7d8423d..a6b8c6c 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -671,16 +671,31 @@ copy_stats(struct statinfo *dest, struct
 static void
 diff_stats(struct statinfo *new, struct statinfo *old)
 {
-	int i, j, is_srv, should_diff;
+	int i, j, is_srv, nodiff_first_index, should_diff;
 
+	/* 
+	 * Different stat types have different formats in the /proc files: for the proc2/3/4-type stats,
+	 * the first entry has the total number of subsequent entries; one does not want to diff that first
+	 * entry.  The other stat types aren't like this.  So, we diff a given entry if it's not of one of
+	 * the procX types ("i" < 2 for clt, < 4 for srv), or if it's not the first entry ("j" > 0).
+	 */
 	is_srv = (new == srvinfo);
+	nodiff_first_index = 2 + (2 * is_srv);
+
 	for (i = 0; old[i].tag; i++) {
 		for (j = 0; j < new[i].nrvals; j++) {
-			/* skip items in valptr that shouldn't be changed */
-			should_diff = (i < (3 + is_srv) || j > 0);
+			should_diff = (i < nodiff_first_index || j > 0);
 			if (should_diff)
 				new[i].valptr[j] -= old[i].valptr[j];
 		}
+
+		/* 
+		 * Make sure that the "totals" entry (last value in each stat array) for the procX-type
+		 * stats has the "numentries" entry's (first value in procX-type stat arrays) constant
+		 * value added-back after the diff -- i.e., it should always be included in the total.
+		 */
+		if (!strncmp("proc", new[i].tag, 4))
+			new[i].valptr[new[i].nrvals - 1] += new[i].valptr[0];
 	}
 }
 
-- 
1.4.4

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

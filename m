From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 2/5] nfsstat: add a comment to has_stats()
Date: Tue, 7 Aug 2007 19:52:50 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071946030.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYr1-0006Jl-Qg
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:49 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYr5-0005s0-Pr
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:52 -0700
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

	Clarify what has_stats() is actually doing.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index d27624e..7d8423d 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -638,10 +638,16 @@ get_stats(const char *file, statinfo *in
 	}
 }
 
+/*
+ * This is for proc2/3/4-type stats, where, in the /proc files, the first entry's value
+ * denotes the number of subsequent entries.  statinfo value arrays contain an additional
+ * field at the end which contains the sum of all previous elements in the array -- so, 
+ * there are stats if the sum's greater than the entry-count.
+ */
 static int
 has_stats(const unsigned int *info)
 {
-	return (info[0] && info[info[0] + 1] != info[0]);
+	return (info[0] && info[info[0] + 1] > info[0]);
 }
 
 /* clone 'src' to 'dest' */
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

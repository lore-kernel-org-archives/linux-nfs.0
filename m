From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 8/8] Add a debug message indicating that gssd is ready
	to process requests
Date: Fri, 30 Mar 2007 18:32:21 -0400
Message-ID: <20070330223221.28802.88828.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPds-0000LV-CB
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:20 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPdu-0006Qw-6a
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:22 -0700
In-Reply-To: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Add a debug message indicating that gssd is ready to process requests

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_main_loop.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 0559f7b..84f04e9 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -116,6 +116,7 @@ gssd_run()
 
 	init_client_list();
 
+	printerr(1, "beginning poll\n");
 	while (1) {
 		while (dir_changed) {
 			dir_changed = 0;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

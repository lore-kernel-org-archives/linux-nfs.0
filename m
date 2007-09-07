From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/2] Fix the usage message for gssd to reflect new
	option
Date: Fri, 07 Sep 2007 10:18:40 -0400
Message-ID: <20070907141840.16229.7985.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070907141603.16229.68150.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITefM-0006mO-SQ
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 07:18:36 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ITefR-00085Y-AT
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 07:18:41 -0700
In-Reply-To: <20070907141603.16229.68150.stgit@RoCk.CiTi.UmIcH.EdU>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Fix the usage message for gssd to reflect new -M option added in 1.1.0

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index b6c4ee4..bbcad20 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -81,7 +81,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir]\n",
+	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir]\n",
 		progname);
 	exit(1);
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

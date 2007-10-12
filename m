From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/9] Fix new warning after strict prototype checking
	enabled
Date: Fri, 12 Oct 2007 16:34:44 -0400
Message-ID: <20071012203444.24796.83504.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRDV-00089N-8a
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:41 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRDZ-0002eF-Bx
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:46 -0700
In-Reply-To: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
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

Fix function declaration to eliminate compiler warning about it
not being a prototype after -Wstrict-prototypes was added.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/svcgssd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 37e0407..4aa157d 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -125,7 +125,7 @@ mydaemon(int nochdir, int noclose)
 }
 
 static void
-release_parent()
+release_parent(void)
 {
 	int status;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/8] Add missing newlines
Date: Fri, 30 Mar 2007 18:32:05 -0400
Message-ID: <20070330223205.28802.84000.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdc-0000IU-QC
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:05 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPde-0006Bh-Oq
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:07 -0700
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

Add missing newlines to error messages.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd_proc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 3b190f2..eff740c 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -555,7 +555,7 @@ #endif
 		ai_hints.ai_protocol = IPPROTO_UDP;
 	} else {
 		printerr(0, "WARNING: unrecognized protocol, '%s', requested "
-			 "for connection to server %s for user with uid %d",
+			 "for connection to server %s for user with uid %d\n",
 			 clp->protocol, clp->servername, uid);
 		goto out_fail;
 	}
@@ -563,12 +563,12 @@ #endif
 	/* extract the service name from clp->servicename */
 	if ((at_sign = strchr(clp->servicename, '@')) == NULL) {
 		printerr(0, "WARNING: servicename (%s) not formatted as "
-			"expected with service@host", clp->servicename);
+			"expected with service@host\n", clp->servicename);
 		goto out_fail;
 	}
 	if ((at_sign - clp->servicename) >= sizeof(service)) {
 		printerr(0, "WARNING: service portion of servicename (%s) "
-			"is too long!", clp->servicename);
+			"is too long!\n", clp->servicename);
 		goto out_fail;
 	}
 	strncpy(service, clp->servicename, at_sign - clp->servicename);
@@ -577,13 +577,13 @@ #endif
 	errcode = getaddrinfo(clp->servername, service, &ai_hints, &a);
 	if (errcode) {
 		printerr(0, "WARNING: Error from getaddrinfo for server "
-			 "'%s': %s", clp->servername, gai_strerror(errcode));
+			 "'%s': %s\n", clp->servername, gai_strerror(errcode));
 		goto out_fail;
 	}
 
 	if (a == NULL) {
 		printerr(0, "WARNING: No address information found for "
-			 "connection to server %s for user with uid %d",
+			 "connection to server %s for user with uid %d\n",
 			 clp->servername, uid);
 		goto out_fail;
 	}
@@ -617,7 +617,7 @@ #endif
 	} else {
 		/* Shouldn't happen! */
 		printerr(0, "ERROR: requested protocol '%s', but "
-			 "got addrinfo with protocol %d",
+			 "got addrinfo with protocol %d\n",
 			 clp->protocol, a->ai_protocol);
 		goto out_fail;
 	}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

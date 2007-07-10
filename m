From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 12/20] scv: Create transport neutral debug bit
	RPCDBG_SVCTRANS
Date: Tue, 10 Jul 2007 00:34:45 -0500
Message-ID: <20070710053445.28979.68036.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88N9-00075S-Gu
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:51 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88NB-0003VW-Te
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:54 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 8ADB07C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:45 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Make the RPCDBG_SVCSOCK debug bit generic for service side
transports.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/debug.h |    2 +-
 net/sunrpc/svcsock.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 3912cf1..d5edad6 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -20,7 +20,7 @@ #define RPCDBG_AUTH		0x0010
 #define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
-#define RPCDBG_SVCSOCK		0x0100
+#define RPCDBG_SVCTRANS		0x0100
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
 #define RPCDBG_CACHE		0x0800
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 57fefea..b88e3d2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -74,7 +74,7 @@ #include <linux/sunrpc/stats.h>
  *
  */
 
-#define RPCDBG_FACILITY	RPCDBG_SVCSOCK
+#define RPCDBG_FACILITY	RPCDBG_SVCTRANS
 
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

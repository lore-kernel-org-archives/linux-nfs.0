From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 5/7] nfsstat: use macros to declare struct statinfo
	arrays
Date: Tue, 31 Jul 2007 17:39:30 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311715550.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzRA-0001Tj-JK
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:29 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzRE-0001m1-E1
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:32 -0700
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

	Use macros to build the arrays of struct statinfos.  This will 
make adding the extra set of temporary variables needed by -D/--diff-stat 
much easier.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 0186fa5..8ec32e2 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -116,28 +116,28 @@ typedef struct statinfo {
 	unsigned int *	valptr;
 } statinfo;
 
-#define STRUCTSIZE(x)   sizeof(x)/sizeof(*x)
-
-static statinfo		srvinfo[] = {
-	{ "net",        STRUCTSIZE(srvnetinfo), srvnetinfo },
-	{ "rpc",        STRUCTSIZE(srvrpcinfo), srvrpcinfo },
-	{ "rc",         STRUCTSIZE(srvrcinfo),  srvrcinfo  },
-	{ "fh",         STRUCTSIZE(srvfhinfo),  srvfhinfo  },
-	{ "proc2",      STRUCTSIZE(srvproc2info),  srvproc2info  },
-	{ "proc3",      STRUCTSIZE(srvproc3info),  srvproc3info  },
-	{ "proc4",      STRUCTSIZE(srvproc4info),  srvproc4info  },
-	{ "proc4ops",   STRUCTSIZE(srvproc4opsinfo),srvproc4opsinfo},
-	{ NULL,         0,                      NULL       }
-};
-
-static statinfo		cltinfo[] = {
-	{ "net",        STRUCTSIZE(cltnetinfo), cltnetinfo },
-	{ "rpc",        STRUCTSIZE(cltrpcinfo), cltrpcinfo },
-	{ "proc2",      STRUCTSIZE(cltproc2info),  cltproc2info  },
-	{ "proc3",      STRUCTSIZE(cltproc3info),  cltproc3info  },
-	{ "proc4",      STRUCTSIZE(cltproc4info),  cltproc4info  },
-	{ NULL,         0,                      NULL       }
-};
+/* 
+ * We now build the arrays of statinfos using macros, which will make it easier
+ * to add new variables for --diff-stat.
+ * e.g., SRV(net) expands into the struct statinfo:  { "net", 5, srvnetinfo }
+ */
+#define ARRAYSIZE(x)		sizeof(x)/sizeof(*x)
+#define STATINFO(k, t, s...)	{ #t, ARRAYSIZE(k##t##info##s), k##t##info##s }
+#define SRV(t, s...)		STATINFO(srv, t, s)
+#define CLT(t, s...)		STATINFO(clt, t, s)
+#define DECLARE_SRV(n, s...)	static statinfo n##s[] = { \
+					SRV(net,s), SRV(rpc,s),   SRV(rc,s),\
+					SRV(fh,s),  SRV(proc2,s), SRV(proc3,s),\
+					SRV(proc4,s), SRV(proc4ops,s),\
+					{ NULL, 0, NULL }\
+				}
+#define DECLARE_CLT(n, s...)  	static statinfo n##s[] = { \
+					CLT(net,s),   CLT(rpc,s), CLT(proc2,s),\
+					CLT(proc3,s), CLT(proc4,s),\
+					{ NULL, 0, NULL }\
+				}
+DECLARE_SRV(srvinfo);
+DECLARE_CLT(cltinfo);
 
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
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

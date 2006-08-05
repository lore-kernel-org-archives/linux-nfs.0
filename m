From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 13/22] lockd: Add nlm_destroy_host
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8080@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lri-00079O-Hr
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrh-0003MK-GK
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:55 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id ADBDC1FFD2
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:48 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

From: Olaf Kirch <okir@suse.de>
Subject: lockd: Add nlm_destroy_host

  This patch moves the host destruction code out of nlm_host_gc
  into a function of its own.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/host.c |   45 +++++++++++++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 16 deletions(-)

Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -164,6 +164,34 @@ out:
 	return host;
 }
 
+/*
+ * Destroy a host
+ */
+static void
+nlm_destroy_host(struct nlm_host *host)
+{
+	struct rpc_clnt	*clnt;
+
+	BUG_ON(!list_empty(&host->h_lockowners));
+	BUG_ON(atomic_read(&host->h_count));
+
+	/*
+	 * Release NSM handle and unmonitor host.
+	 */
+	nsm_unmonitor(host);
+
+	if ((clnt = host->h_rpcclnt) != NULL) {
+		if (atomic_read(&clnt->cl_users)) {
+			printk(KERN_WARNING
+				"lockd: active RPC handle\n");
+			clnt->cl_dead = 1;
+		} else {
+			rpc_destroy_client(host->h_rpcclnt);
+		}
+	}
+	kfree(host);
+}
+
 struct nlm_host *
 nlm_find_client(void)
 {
@@ -396,7 +424,6 @@ nlm_gc_hosts(void)
 	struct hlist_head *chain;
 	struct hlist_node *pos, *next;
 	struct nlm_host	*host;
-	struct rpc_clnt	*clnt;
 
 	dprintk("lockd: host garbage collection\n");
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
@@ -419,21 +446,7 @@ nlm_gc_hosts(void)
 			dprintk("lockd: delete host %s\n", host->h_name);
 			hlist_del_init(&host->h_hash);
 
-			/*
-			 * Unmonitor unless host was invalidated (i.e. lockd restarted)
-			 */
-			nsm_unmonitor(host);
-
-			if ((clnt = host->h_rpcclnt) != NULL) {
-				if (atomic_read(&clnt->cl_users)) {
-					printk(KERN_WARNING
-						"lockd: active RPC handle\n");
-					clnt->cl_dead = 1;
-				} else {
-					rpc_destroy_client(host->h_rpcclnt);
-				}
-			}
-			kfree(host);
+			nlm_destroy_host(host);
 			nrhosts--;
 		}
 	}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

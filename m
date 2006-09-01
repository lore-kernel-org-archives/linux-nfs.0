From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 19] knfsd: lockd: Add nlm_destroy_host
Date: Fri, 1 Sep 2006 14:39:11 +1000
Message-ID: <1060901043911.27582@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0oL-0005tm-N6
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:21 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0oJ-0001TU-M6
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:22 -0700
To: Andrew Morton <akpm@osdl.org>
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

  This patch moves the host destruction code out of nlm_host_gc
  into a function of its own.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/host.c |   45 +++++++++++++++++++++++++++++----------------
 1 file changed, 29 insertions(+), 16 deletions(-)

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-08-31 17:32:46.000000000 +1000
+++ ./fs/lockd/host.c	2006-09-01 11:07:19.000000000 +1000
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
@@ -400,7 +428,6 @@ nlm_gc_hosts(void)
 	struct hlist_head *chain;
 	struct hlist_node *pos, *next;
 	struct nlm_host	*host;
-	struct rpc_clnt	*clnt;
 
 	dprintk("lockd: host garbage collection\n");
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
@@ -423,21 +450,7 @@ nlm_gc_hosts(void)
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
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

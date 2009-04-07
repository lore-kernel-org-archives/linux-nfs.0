From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/5] nfs-utils: switch gssd to use standard function for
	getting an RPC client
Date: Tue,  7 Apr 2009 11:25:45 -0400
Message-ID: <1239117946-7535-5-git-send-email-jlayton@redhat.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

We already have a common function for setting up an RPC client. That
function uses the tirpc API when tirpc is enabled and is also already
IPv6 enabled. Switch gssd to use it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   41 ++++++++++++-----------------------------
 1 files changed, 12 insertions(+), 29 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1571329..5b97d6c 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -616,9 +616,8 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	int			retval = -1;
 	OM_uint32		min_stat;
 	char			rpc_errmsg[1024];
-	int			sockp = RPC_ANYSOCK;
-	int			sendsz = 32768, recvsz = 32768;
 	int			protocol;
+	struct timeval		timeout = {5, 0};
 	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
 	socklen_t		salen;
 
@@ -698,33 +697,17 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	if (!populate_port(addr, salen, clp->prog, clp->vers, protocol))
 		goto out_fail;
 
-	if (protocol == IPPROTO_TCP) {
-		if ((rpc_clnt = clnttcp_create(
-					(struct sockaddr_in *) addr,
-					clp->prog, clp->vers, &sockp,
-					sendsz, recvsz)) == NULL) {
-			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
-				 "WARNING: can't create tcp rpc_clnt "
-				 "for server %s for user with uid %d",
-				 clp->servername, uid);
-			printerr(0, "%s\n",
-				 clnt_spcreateerror(rpc_errmsg));
-			goto out_fail;
-		}
-	} else if (protocol == IPPROTO_UDP) {
-		const struct timeval timeout = {5, 0};
-		if ((rpc_clnt = clntudp_bufcreate(
-					(struct sockaddr_in *) addr,
-					clp->prog, clp->vers, timeout,
-					&sockp, sendsz, recvsz)) == NULL) {
-			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
-				 "WARNING: can't create udp rpc_clnt "
-				 "for server %s for user with uid %d",
-				 clp->servername, uid);
-			printerr(0, "%s\n",
-				 clnt_spcreateerror(rpc_errmsg));
-			goto out_fail;
-		}
+	rpc_clnt = nfs_get_rpcclient(addr, salen, protocol, clp->prog,
+				     clp->vers, &timeout);
+	if (!rpc_clnt) {
+		snprintf(rpc_errmsg, sizeof(rpc_errmsg),
+			 "WARNING: can't create %s rpc_clnt to server %s for "
+			 "user with uid %d",
+			 protocol == IPPROTO_TCP ? "tcp" : "udp",
+			 clp->servername, uid);
+		printerr(0, "%s\n",
+			 clnt_spcreateerror(rpc_errmsg));
+		goto out_fail;
 	}
 
 	printerr(2, "creating context with server %s\n", clp->servicename);
-- 
1.6.0.6

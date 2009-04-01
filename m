From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/6] nfs-utils: when TIRPC is enabled,
	use new API to create RPC client
Date: Wed,  1 Apr 2009 10:24:04 -0400
Message-ID: <1238595845-2186-6-git-send-email-jlayton@redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
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

When we add IPv6 code, we'll need to use the newer API to create
the rpc client. Add a new rpc client creation function that's
conditionally compiled in whenever TIRPC is enabled.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b88b0c6..2d7b58d 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -537,6 +537,81 @@ out_err:
 	return -1;
 }
 
+#ifdef HAVE_LIBTIRPC
+static CLIENT *
+create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
+{
+	CLIENT			*rpc_clnt = NULL;
+	char			rpc_errmsg[1024];
+	int			sendsz = 32768, recvsz = 32768;
+	struct netconfig	*nc = NULL;
+	struct netbuf		nb;
+	const struct timeval	timeout = {5, 0};
+	void 			*handle = NULL;
+	char			*nc_protofmly;
+	struct protoent		*proto;
+	sa_family_t		af = ((struct sockaddr *) &clp->addr)->sa_family;
+
+	proto = getprotobynumber(protocol);
+	if (proto == NULL) {
+		printerr(0, "ERROR: can't resolve %d to protocol\n",
+			 protocol);
+		goto out;
+	}
+
+	switch(af) {
+	case AF_INET:
+		nc_protofmly = NC_INET;
+		nb.len = nb.maxlen = sizeof(struct sockaddr_in);
+		break;
+	default:
+		printerr(0, "ERROR: unsupported address family %hd\n", af);
+		goto out;
+	}
+
+	handle = setnetconfig();
+	while ((nc = getnetconfig(handle)) != NULL) {
+
+		if (nc->nc_protofmly != NULL &&
+		    strcmp(nc->nc_protofmly, nc_protofmly) != 0)
+			continue;
+		if (nc->nc_proto != NULL &&
+		    strcmp(nc->nc_proto, proto->p_name) != 0)
+			continue;
+
+		break;
+	}
+
+	if (!nc) {
+		printerr(0, "ERROR: unable to find netconfig entry for "
+			    "addr family %hd and proto %d\n",
+			    af, protocol);
+		goto out;
+	}
+
+	nb.buf = &clp->addr;
+
+	rpc_clnt = clnt_tli_create(RPC_ANYFD, nc, &nb, clp->prog, clp->vers,
+				   sendsz, recvsz);
+	if (!rpc_clnt) {
+		snprintf(rpc_errmsg, sizeof(rpc_errmsg),
+			 "ERROR: unable to create %s RPC client for %s with "
+			 "uid %d", clp->protocol, clp->servername, uid);
+		printerr(0, "%s\n", clnt_spcreateerror(rpc_errmsg));
+		goto out;
+	}
+
+	/* set retry timeout for connectionless transports */
+	if (nc->nc_semantics == NC_TPI_CLTS)
+		clnt_control(rpc_clnt, CLSET_RETRY_TIMEOUT, (void *) &timeout);
+out:
+	if (handle)
+		endnetconfig(handle);
+	return rpc_clnt;
+}
+
+#else  /* HAVE_LIBTIRPC */
+
 static CLIENT *
 create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
 {
@@ -582,6 +657,7 @@ create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
 
 	return rpc_clnt;
 }
+#endif /* HAVE_LIBTIRPC */
 
 /*
  * Determine the port from the servicename and set the right field in the
-- 
1.6.0.6

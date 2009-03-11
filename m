From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/6] nfs-utils: when TIRPC is enabled, use new API to create RPC client
Date: Wed, 11 Mar 2009 12:43:01 -0400
Message-ID: <1236789782-8867-6-git-send-email-jlayton@redhat.com>
References: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
Cc: kwc@citi.umich.edu, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32908 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752319AbZCKQnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 12:43:14 -0400
In-Reply-To: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we add IPv6 code, we'll need to use the newer API to create
the rpc client. Add a new rpc client creation function that's
conditionally compiled in whenever TIRPC is enabled.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 5cf2445..1e3dabc 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -552,6 +552,81 @@ out_err:
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
+
+	proto = getprotobynumber(protocol);
+	if (proto == NULL) {
+		printerr(0, "ERROR: can't resolve %d to protocol\n",
+			 protocol);
+		goto out;
+	}
+
+	switch(clp->addr->ss_family) {
+	case AF_INET:
+		nc_protofmly = NC_INET;
+		nb.len = nb.maxlen = sizeof(struct sockaddr_in);
+		break;
+	default:
+		printerr(0, "ERROR: unsupported address family %d\n",
+			    clp->addr->ss_family);
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
+			    "addr family %d and proto %d\n",
+			    clp->addr->ss_family, protocol);
+		goto out;
+	}
+
+	nb.buf = clp->addr;
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
@@ -597,6 +672,7 @@ create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
 
 	return rpc_clnt;
 }
+#endif /* HAVE_LIBTIRPC */
 
 /*
  * Determine the port from the servicename and set the right field in the
-- 
1.6.0.6


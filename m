From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/6] nfsd: populate sin6_scope_id on callback address with
	scopeid from rq_addr on SETCLIENTID call
Date: Fri, 14 Aug 2009 12:57:59 -0400
Message-ID: <1250269079-14629-7-git-send-email-jlayton@redhat.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org, chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

When a SETCLIENTID call comes in, one of the args given is the svc_rqst.
This struct contains an rq_addr field which holds the address that sent
the call. If this is an IPv6 address, then we can use the sin6_scope_id
field in this address to populate the sin6_scope_id field in the
callback address.

AFAICT, the rq_addr.sin6_scope_id is non-zero if and only if the client
mounted the server's link-local address.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c         |    7 +++++--
 include/linux/sunrpc/clnt.h |   15 +++++++++++++++
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9ec0ca1..d2a0524 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -898,7 +898,7 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 }
 
 static void
-gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
+gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	unsigned short expected_family;
@@ -921,6 +921,9 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if (!cb->cb_addrlen || cb->cb_addr.ss_family != expected_family)
 		goto out_err;
 
+	if (cb->cb_addr.ss_family == AF_INET6)
+		((struct sockaddr_in6 *) &cb->cb_addr)->sin6_scope_id = scopeid;
+
 	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
@@ -1621,7 +1624,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	copy_cred(&new->cl_cred, &rqstp->rq_cred);
 	gen_confirm(new);
-	gen_callback(new, setclid);
+	gen_callback(new, setclid, rpc_get_scope_id(sa));
 	add_to_unconfirmed(new, strhashval);
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 044f531..3d02558 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -286,5 +286,20 @@ static inline bool rpc_copy_addr(struct sockaddr *dst,
 	return false;
 }
 
+/**
+ * rpc_get_scope_id - return scopeid for a given sockaddr
+ * @sa: sockaddr to get scopeid from
+ *
+ * Returns the value of the sin6_scope_id for AF_INET6 addrs, or 0 if
+ * not an AF_INET6 address.
+ */
+static inline u32 rpc_get_scope_id(const struct sockaddr *sa)
+{
+	if (sa->sa_family != AF_INET6)
+		return 0;
+
+	return ((struct sockaddr_in6 *) sa)->sin6_scope_id;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
-- 
1.6.0.6

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 23] Preparation for delegation: client callback probe
Date: Fri, 17 Dec 2004 16:23:55 +1100
Message-ID: <E1CfAap-0002dc-GG@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbM-00059Y-Cr
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:28 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbI-0004CA-Fl
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:28 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


client callback rpc to probe the callback
channel on setclientid with a null request.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/Makefile           |    2 
 ./fs/nfsd/nfs4callback.c     |  269 +++++++++++++++++++++++++++++++++++++++++++
 ./include/linux/nfsd/state.h |    1 
 3 files changed, 271 insertions(+), 1 deletion(-)

diff ./fs/nfsd/Makefile~current~ ./fs/nfsd/Makefile
--- ./fs/nfsd/Makefile~current~	2004-12-15 11:51:29.000000000 +1100
+++ ./fs/nfsd/Makefile	2004-12-15 11:51:29.000000000 +1100
@@ -8,5 +8,5 @@ nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o
 			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
-			   nfs4acl.o
+			   nfs4acl.o nfs4callback.o
 nfsd-objs		:= $(nfsd-y)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2004-12-15 11:51:29.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2004-12-15 11:51:29.000000000 +1100
@@ -0,0 +1,269 @@
+/*
+ *  linux/fs/nfsd/nfs4callback.c
+ *
+ *  Copyright (c) 2001 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Kendrick Smith <kmsmith@umich.edu>
+ *  Andy Adamson <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/inet.h>
+#include <linux/errno.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfsd/nfsd.h>
+#include <linux/nfsd/state.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs4.h>
+
+#define NFSDDBG_FACILITY                NFSDDBG_PROC
+
+#define NFSPROC4_CB_NULL 0
+
+/* forward declarations */
+static void nfs4_cb_null(struct rpc_task *task);
+
+/* Index of predefined Linux callback client operations */
+
+enum {
+        NFSPROC4_CLNT_CB_NULL = 0,
+};
+
+#define NFS4_MAXTAGLEN		20
+
+#define NFS4_enc_cb_null_sz		0
+#define NFS4_dec_cb_null_sz		0
+
+/*
+* Generic encode routines from fs/nfs/nfs4xdr.c
+*/
+#define RESERVE_SPACE(nbytes)   do {                            \
+	p = xdr_reserve_space(xdr, nbytes);                     \
+	if (!p) dprintk("NFSD: RESERVE_SPACE(%d) failed in function %s\n", (int) (nbytes), __FUNCTION__); \
+	BUG_ON(!p);                                             \
+} while (0)
+
+/*
+ * XDR encode
+ */
+
+static int
+nfs4_xdr_enc_cb_null(struct rpc_rqst *req, u32 *p)
+{
+	struct xdr_stream xdrs, *xdr = &xdrs;
+
+	xdr_init_encode(&xdrs, &req->rq_snd_buf, p);
+        RESERVE_SPACE(0);
+	return 0;
+}
+
+static int
+nfs4_xdr_dec_cb_null(struct rpc_rqst *req, u32 *p)
+{
+	return 0;
+}
+
+/*
+ * RPC procedure tables
+ */
+#ifndef MAX
+# define MAX(a, b)      (((a) > (b))? (a) : (b))
+#endif
+
+#define PROC(proc, call, argtype, restype)                              \
+[NFSPROC4_CLNT_##proc] = {                                      	\
+        .p_proc   = NFSPROC4_CB_##call,					\
+        .p_encode = (kxdrproc_t) nfs4_xdr_##argtype,                    \
+        .p_decode = (kxdrproc_t) nfs4_xdr_##restype,                    \
+        .p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,  \
+}
+
+struct rpc_procinfo     nfs4_cb_procedures[] = {
+    PROC(CB_NULL,      NULL,     enc_cb_null,     dec_cb_null),
+};
+
+struct rpc_version              nfs_cb_version4 = {
+        .number                 = 1,
+        .nrprocs                = sizeof(nfs4_cb_procedures)/sizeof(nfs4_cb_procedures[0]),
+        .procs                  = nfs4_cb_procedures
+};
+
+static struct rpc_version *	nfs_cb_version[] = {
+	NULL,
+	&nfs_cb_version4,
+};
+
+/*
+ * Use the SETCLIENTID credential
+ */
+struct rpc_cred *
+nfsd4_lookupcred(struct nfs4_client *clp, int taskflags)
+{
+        struct auth_cred acred;
+	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+        struct rpc_cred *ret = NULL;
+
+	if (!clnt)
+		goto out;
+        get_group_info(clp->cl_cred.cr_group_info);
+        acred.uid = clp->cl_cred.cr_uid;
+        acred.gid = clp->cl_cred.cr_gid;
+        acred.group_info = clp->cl_cred.cr_group_info;
+
+        dprintk("NFSD:     looking up %s cred\n",
+                clnt->cl_auth->au_ops->au_name);
+        ret = rpcauth_lookup_credcache(clnt->cl_auth, &acred, taskflags);
+        put_group_info(clp->cl_cred.cr_group_info);
+out:
+        return ret;
+}
+
+/*
+ * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
+ */
+void
+nfsd4_probe_callback(struct nfs4_client *clp)
+{
+	struct sockaddr_in	addr;
+	struct nfs4_callback    *cb = &clp->cl_callback;
+	struct rpc_timeout	timeparms;
+	struct rpc_xprt *	xprt;
+	struct rpc_program *	program = &cb->cb_program;
+	struct rpc_stat *	stat = &cb->cb_stat;
+	struct rpc_clnt *	clnt;
+	struct rpc_message msg = {
+		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
+		.rpc_argp       = clp,
+	};
+	char                    hostname[32];
+	int status;
+
+	dprintk("NFSD: probe_callback. cb_parsed %d cb_set %d\n",
+			cb->cb_parsed, atomic_read(&cb->cb_set));
+	if (!cb->cb_parsed || atomic_read(&cb->cb_set))
+		return;
+
+	/* Initialize address */
+	memset(&addr, 0, sizeof(addr));
+	addr.sin_family = AF_INET;
+	addr.sin_port = htons(cb->cb_port);
+	addr.sin_addr.s_addr = htonl(cb->cb_addr);
+
+	/* Initialize timeout */
+	timeparms.to_initval = (NFSD_LEASE_TIME/4) * HZ;
+	timeparms.to_retries = 5;
+	timeparms.to_maxval = (NFSD_LEASE_TIME/2) * HZ;
+	timeparms.to_exponential = 1;
+
+	/* Create RPC transport */
+	if (!(xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms))) {
+		dprintk("NFSD: couldn't create callback transport!\n");
+		goto out_err;
+	}
+
+	/* Initialize rpc_program */
+	program->name = "nfs4_cb";
+	program->number = cb->cb_prog;
+	program->nrvers = sizeof(nfs_cb_version)/sizeof(nfs_cb_version[0]);
+	program->version = nfs_cb_version;
+	program->stats = stat;
+
+	/* Initialize rpc_stat */
+	memset(stat, 0, sizeof(struct rpc_stat));
+	stat->program = program;
+
+	/* Create RPC client
+ 	 *
+	 * XXX AUTH_UNIX only - need AUTH_GSS....
+	 */
+	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
+	if (!(clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX))) {
+		dprintk("NFSD: couldn't create callback client\n");
+		goto out_xprt;
+	}
+	clnt->cl_intr = 1;
+	clnt->cl_softrtry = 1;
+	clnt->cl_chatty = 1;
+	cb->cb_client = clnt;
+
+	/* Kick rpciod, put the call on the wire. */
+
+	if (rpciod_up() != 0) {
+		dprintk("nfsd: couldn't start rpciod for callbacks!\n");
+		goto out_clnt;
+	}
+
+	/* the task holds a reference to the nfs4_client struct */
+	atomic_inc(&clp->cl_count);
+
+	msg.rpc_cred = nfsd4_lookupcred(clp,0);
+	status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, nfs4_cb_null, NULL);
+
+	if (status != 0) {
+		dprintk("NFSD: asynchronous NFSPROC4_CB_NULL failed!\n");
+		goto out_rpciod;
+	}
+	return;
+
+out_rpciod:
+	rpciod_down();
+out_clnt:
+	rpc_shutdown_client(clnt);
+	goto out_err;
+out_xprt:
+	xprt_destroy(xprt);
+out_err:
+	dprintk("NFSD: warning: no callback path to client %.*s\n",
+		clp->cl_name.len, clp->cl_name.data);
+	cb->cb_client = NULL;
+}
+
+static void
+nfs4_cb_null(struct rpc_task *task)
+{
+	struct nfs4_client *clp = (struct nfs4_client *)task->tk_msg.rpc_argp;
+	struct nfs4_callback *cb = &clp->cl_callback;
+	u32 addr = htonl(cb->cb_addr);
+
+	dprintk("NFSD: nfs4_cb_null task->tk_status %d\n", task->tk_status);
+
+	if (task->tk_status < 0) {
+		dprintk("NFSD: callback establishment to client %.*s failed\n",
+			clp->cl_name.len, clp->cl_name.data);
+		goto out;
+	}
+	atomic_set(&cb->cb_set, 1);
+	dprintk("NFSD: callback set to client %u.%u.%u.%u\n", NIPQUAD(addr));
+out:
+	put_nfs4_client(clp);
+}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-12-15 11:49:34.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-12-15 11:51:29.000000000 +1100
@@ -253,6 +253,7 @@ extern int nfs4_in_grace(void);
 extern int nfs4_check_open_reclaim(clientid_t *clid);
 extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
+extern void nfsd4_probe_callback(struct nfs4_client *clp);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

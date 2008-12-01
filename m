From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] NSM: Support IPv6 version of mon_name
Date: Mon, 01 Dec 2008 13:57:50 -0500
Message-ID: <20081201185749.10600.38468.stgit@ingres.1015granger.net>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:33502 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbYLAS6n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:58:43 -0500
In-Reply-To: <20081201185108.10600.21700.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "mon_name" argument of the NSMPROC_MON and NSMPROC_UNMON upcalls
is a string that contains the hostname or IP address of the remote peer
to be notified when this host has rebooted.  The sm-notify command uses
this identifier to contact the peer when we reboot, so it must be
either a well-qualified DNS hostname or a presentation format IP
address string.

When the "nsm_use_hostnames" sysctl is set to zero, the kernel's NSM
provides a presentation format IP address in the "mon_name" argument.
Otherwise, the "caller_name" argument from NLM requests is used,
which is usually just the DNS hostname of the peer.

To support IPv6 addresses for the mon_name argument, we use the
nsm_handle's address eye-catcher, which already contains an appropriate
presentation format address string.  Using the eye-catcher string
obviates the need to use a large buffer on the stack to form the
presentation address string for the upcall.

This patch also addresses a subtle bug.

An NSMPROC_MON request and the subsequent NSMPROC_UNMON request for the
same peer are required to use the same value for the "mon_name"
argument.  Otherwise, rpc.statd's NSMPROC_UNMON processing cannot
locate the database entry for that peer and remove it.

If the setting of nsm_use_hostnames is changed between the time the
kernel sends an NSMPROC_MON request and the time it sends the
NSMPROC_UNMON request for the same peer, the "mon_name" argument for
these two requests may not be the same.  This is because the value of
"mon_name" is currently chosen at the moment the call is made based on
the setting of nsm_use_hostnames

To ensure both requests pass identical contents in the "mon_name"
argument, we now select which string to use for the argument in the
nsm_monitor() function.  A pointer to this string is saved in the
nsm_handle so it can be used for the subsequent NSMPROC_UNMON upcall.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c              |   45 +++++++++++++++++--------------------------
 include/linux/lockd/lockd.h |    1 +
 2 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4e7e958..a606fbb 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,8 +18,6 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
-#define XDR_ADDRBUF_LEN		(20)
-
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
@@ -37,7 +35,13 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
-	struct nsm_args	args;
+	struct nsm_args args = {
+		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
+		.prog		= NLM_PROGRAM,
+		.vers		= 3,
+		.proc		= NLMPROC_NSM_NOTIFY,
+		.mon_name	= nsm->sm_mon_name,
+	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
 		.rpc_resp	= res,
@@ -46,22 +50,18 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	clnt = nsm_create();
 	if (IS_ERR(clnt)) {
 		status = PTR_ERR(clnt);
+		dprintk("lockd: failed to create NSM upcall transport, "
+				"status=%d\n", status);
 		goto out;
 	}
 
-	memset(&args, 0, sizeof(args));
-	args.mon_name = nsm->sm_name;
-	args.addr = nsm_addr_in(nsm)->sin_addr.s_addr;
-	args.prog = NLM_PROGRAM;
-	args.vers = 3;
-	args.proc = NLMPROC_NSM_NOTIFY;
 	memset(res, 0, sizeof(*res));
 
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
 	status = rpc_call_sync(clnt, &msg, 0);
 	if (status < 0)
-		printk(KERN_DEBUG "nsm_mon_unmon: rpc failed, status=%d\n",
-			status);
+		dprintk("lockd: NSM upcall RPC failed, status=%d\n",
+				status);
 	else
 		status = 0;
 	rpc_shutdown_client(clnt);
@@ -85,6 +85,12 @@ nsm_monitor(struct nlm_host *host)
 	if (nsm->sm_monitored)
 		return 0;
 
+	/*
+	 * Choose whether to record the caller_name or IP address of
+	 * this peer in the local rpc.statd's database.
+	 */
+	nsm->sm_mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
+
 	status = nsm_mon_unmon(nsm, SM_MON, &res);
 
 	if (status < 0 || res.status != 0)
@@ -165,25 +171,10 @@ static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
 
 /*
  * "mon_name" specifies the host to be monitored.
- *
- * Linux uses a text version of the IP address of the remote
- * host as the host identifier (the "mon_name" argument).
- *
- * Linux statd always looks up the canonical hostname first for
- * whatever remote hostname it receives, so this works alright.
  */
 static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 {
-	char	buffer[XDR_ADDRBUF_LEN + 1];
-	char	*name = argp->mon_name;
-
-	if (!nsm_use_hostnames) {
-		snprintf(buffer, XDR_ADDRBUF_LEN,
-			 NIPQUAD_FMT, NIPQUAD(argp->addr));
-		name = buffer;
-	}
-
-	return xdr_encode_nsm_string(p, name);
+	return xdr_encode_nsm_string(p, argp->mon_name);
 }
 
 /*
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 307a8f0..de9ea7b 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -73,6 +73,7 @@ struct nsm_handle {
 	char *			sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;
+	char *			sm_mon_name;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
 	char			sm_addrbuf[63];	/* presentation address */


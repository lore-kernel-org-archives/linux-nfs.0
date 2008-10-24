From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/14] NSM: Support IPv6 version of mon_name
Date: Fri, 24 Oct 2008 14:10:09 -0400
Message-ID: <20081024181009.23810.56793.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41786 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbYJXSL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:26 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBJ9S009710
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:20 -0500
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9O5chwF030536
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:17 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIA9bs023909
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:09 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the "nsm_use_hostnames" sysctl is set to zero, the kernel's NSM
provides a presentation format IP address in the mon_name argument of
SM_MON upcalls.  This is part of the private interface between Linux's
rpc.statd and the kernel's lockd implementation.  Linux's rpc.statd
can then resolve this address with DNS as a sanity check.

To support IPv6 addresses for the mon_name argument, just point the
XDR encoder to the nsm_handle's eye-catcher, which already contains a
presentation format address string.

Finally, provide some debugging message clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   43 +++++++++++++++----------------------------
 1 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index a5c6ec4..1c058b1 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,8 +18,6 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
-#define XDR_ADDRBUF_LEN		(20)
-
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
@@ -40,7 +38,14 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
-	struct nsm_args	args;
+	struct nsm_args	args = {
+		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
+		.prog		= NLM_PROGRAM,
+		.vers		= 3,
+		.proc		= NLMPROC_NSM_NOTIFY,
+		.mon_name	= nsm_use_hostnames ?
+					nsm->sm_name : nsm->sm_addrbuf,
+	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
 		.rpc_resp	= res,
@@ -49,24 +54,21 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	clnt = nsm_create();
 	if (IS_ERR(clnt)) {
 		status = PTR_ERR(clnt);
+		dprintk("lockd: failed to create nsm transport, "
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
-	else
+		dprintk("lockd: nsm rpc failed, status=%d\n", status);
+	else {
 		status = 0;
+		dprintk("lockd: monitoring '%s'\n", args.mon_name);
+	}
 	rpc_shutdown_client(clnt);
  out:
 	return status;
@@ -253,25 +255,10 @@ static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
 
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


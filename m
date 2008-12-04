From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/17] NSM: Support IPv6 version of mon_name
Date: Thu, 04 Dec 2008 14:20:46 -0500
Message-ID: <20081204192045.8039.69926.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50167 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497AbYLDTV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:28 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
nsm_handle so it can be used for a subsequent NSMPROC_UNMON upcall.

NB: There are other potential problems, such as how nlm_host_rebooted()
might behave if nsm_use_hostnames were changed while hosts are still
being monitored.  This patch does not attempt to address those
problems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c              |   27 ++++++++-------------------
 include/linux/lockd/lockd.h |    1 +
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 2694a49..a606fbb 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,8 +18,6 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
-#define XDR_ADDRBUF_LEN		(20)
-
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
@@ -42,7 +40,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 		.prog		= NLM_PROGRAM,
 		.vers		= 3,
 		.proc		= NLMPROC_NSM_NOTIFY,
-		.mon_name	= nsm->sm_name,
+		.mon_name	= nsm->sm_mon_name,
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
@@ -87,6 +85,12 @@ nsm_monitor(struct nlm_host *host)
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
@@ -167,25 +171,10 @@ static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
 
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
index 54dbb45..d3c7247 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -79,6 +79,7 @@ struct nlm_host {
 struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
+	char			*sm_mon_name;
 	char			*sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;


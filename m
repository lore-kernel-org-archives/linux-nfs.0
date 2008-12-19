From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] backwards compatibility: fix order of fields in TI-RPC's
	svc_req
Date: Fri, 19 Dec 2008 10:31:33 -0500
Message-ID: <20081219153133.32332.48865.stgit@ingres.1015granger.net>
References: <20081219152226.32332.5510.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: =okir@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:53738 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYLSPf7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2008 10:35:59 -0500
In-Reply-To: <20081219152226.32332.5510.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preserve ABI compatibility between glibc's RPC implementation and
the legacy RPC implementation in libtirpc by moving the rq_xprt
field in the TI-RPC version of the svc_req struct so it is
backwards compatible with the legacy version of this structure.

Linux's legacy svc_req struct, from /usr/include/rpc/svc.h, looks
like this:

struct svc_req {
  rpcprog_t rq_prog;		/* service program number */
  rpcvers_t rq_vers;		/* service protocol version */
  rpcproc_t rq_proc;		/* the desired procedure */
  struct opaque_auth rq_cred;	/* raw creds from the wire */
  caddr_t rq_clntcred;		/* read only cooked cred */
  SVCXPRT *rq_xprt;		/* associated transport */
};

The new TI-RPC svc_req struct, from /usr/include/tirpc/rpc/svc.h,
looks like this:

struct svc_req {
  u_int32_t rq_prog;		/* service program number */
  u_int32_t rq_vers;		/* service protocol version */
  u_int32_t rq_proc;		/* the desired procedure */
  struct opaque_auth rq_cred;	/* raw creds from the wire */
  void *rq_clntcred;		/* read only cooked cred */
  caddr_t rq_clntname;		/* read only client name */
  caddr_t rq_svcname;		/* read only cooked service cred */
  SVCXPRT *rq_xprt;		/* associated transport */
};

Note the extra fields rq_clntname and rq_svcname.  These are used for
TI-RPC's RPCSEC GSS flavor support.

This issue came to light because rpc.statd still uses only legacy RPC
calls, and thus includes /usr/include/rpc/svc.h.  However, other parts
of nfs-utils now link with TI-RPC, so the legacy RPC functions in
libtirpc are used in favor of glibc's RPC functions.  The libtirpc svc
functions use the new svc_req struct, but rpc.statd uses the old
svc_req struct.

Since the svc_req fields were different, rpc.statd broke after recent
IPv6-related changes, even though I hadn't made any changes to it.
Note that rpc.mountd also references the rq_xprt field, so it has the
same issue.

In most operating systems, there is only one rpc/svc.h and one version
of svc_req so this is not a problem.  We should audit all of the
structures and functions under /usr/include/rpc and
/usr/include/tirpc/rpc to ensure we have a reasonable level of
backwards compatibility until such a time it is decided to merge these
implementations or get rid of RPC support in glibc.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 tirpc/rpc/svc.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tirpc/rpc/svc.h b/tirpc/rpc/svc.h
index ec5914f..ea2985d 100644
--- a/tirpc/rpc/svc.h
+++ b/tirpc/rpc/svc.h
@@ -131,14 +131,17 @@ typedef struct __rpc_svcxprt {
  * Service request
  */
 struct svc_req {
+	/* ORDER: compatibility with legacy RPC */
 	u_int32_t	rq_prog;	/* service program number */
 	u_int32_t	rq_vers;	/* service protocol version */
 	u_int32_t	rq_proc;	/* the desired procedure */
 	struct opaque_auth rq_cred;	/* raw creds from the wire */
 	void		*rq_clntcred;	/* read only cooked cred */
+	SVCXPRT		*rq_xprt;	/* associated transport */
+
+	/* New with TI-RPC */
 	caddr_t		rq_clntname;	/* read only client name */
 	caddr_t		rq_svcname;	/* read only cooked service cred */
-	SVCXPRT		*rq_xprt;	/* associated transport */
 };
 
 /*


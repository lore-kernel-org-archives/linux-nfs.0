Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:47855 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756632Ab2INOc4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 10:32:56 -0400
Subject: [PATCH 1/3] lockd: use rpc client's cl_nodename for id encoding
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Fri, 14 Sep 2012 18:25:55 +0400
Message-ID: <20120914142555.10835.53544.stgit@localhost.localdomain>
In-Reply-To: <20120914140811.10835.81465.stgit@localhost.localdomain>
References: <20120914140811.10835.81465.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Taking hostname from uts namespace if not safe, because this cuold be
performind during umount operation on child reaper death. And in this case
current->nsproxy is NULL already.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: <stable@vger.kernel.org>
---
 fs/lockd/mon.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 7ef14b3..c6186fb 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -426,11 +426,12 @@ static void encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
  * (via the NLMPROC_SM_NOTIFY call) that the state of host "mon_name"
  * has changed.
  */
-static void encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
+static void encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp,
+			 char *nodename)
 {
 	__be32 *p;
 
-	encode_nsm_string(xdr, utsname()->nodename);
+	encode_nsm_string(xdr, nodename);
 	p = xdr_reserve_space(xdr, 4 + 4 + 4);
 	*p++ = cpu_to_be32(argp->prog);
 	*p++ = cpu_to_be32(argp->vers);
@@ -441,10 +442,11 @@ static void encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
  * The "mon_id" argument specifies the non-private arguments
  * of an NSMPROC_MON or NSMPROC_UNMON call.
  */
-static void encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
+static void encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp,
+			  char *nodename)
 {
 	encode_mon_name(xdr, argp);
-	encode_my_id(xdr, argp);
+	encode_my_id(xdr, argp, nodename);
 }
 
 /*
@@ -463,14 +465,14 @@ static void encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 static void nsm_xdr_enc_mon(struct rpc_rqst *req, struct xdr_stream *xdr,
 			    const struct nsm_args *argp)
 {
-	encode_mon_id(xdr, argp);
+	encode_mon_id(xdr, argp, req->rq_task->tk_client->cl_nodename);
 	encode_priv(xdr, argp);
 }
 
 static void nsm_xdr_enc_unmon(struct rpc_rqst *req, struct xdr_stream *xdr,
 			      const struct nsm_args *argp)
 {
-	encode_mon_id(xdr, argp);
+	encode_mon_id(xdr, argp, req->rq_task->tk_client->cl_nodename);
 }
 
 static int nsm_xdr_dec_stat_res(struct rpc_rqst *rqstp,


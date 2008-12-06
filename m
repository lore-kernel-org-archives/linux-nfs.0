From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/27] NSM: Switch over to the new-style XDR functions
Date: Fri, 05 Dec 2008 19:02:30 -0500
Message-ID: <20081206000229.24075.41381.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:16718 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbYLFAE3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:29 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new xdr_stream-based XDR encoder and decoder functions instead of the
old-style functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 0f8e029..67cce9f 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -428,8 +428,8 @@ static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
 static struct rpc_procinfo	nsm_procedures[] = {
 [NSMPROC_MON] = {
 		.p_proc		= NSMPROC_MON,
-		.p_encode	= (kxdrproc_t) xdr_encode_mon,
-		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
+		.p_encode	= (kxdrproc_t)xdr_enc_mon,
+		.p_decode	= (kxdrproc_t)xdr_dec_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
 		.p_statidx	= NSMPROC_MON,
@@ -437,8 +437,8 @@ static struct rpc_procinfo	nsm_procedures[] = {
 	},
 [NSMPROC_UNMON] = {
 		.p_proc		= NSMPROC_UNMON,
-		.p_encode	= (kxdrproc_t) xdr_encode_unmon,
-		.p_decode	= (kxdrproc_t) xdr_decode_stat,
+		.p_encode	= (kxdrproc_t)xdr_enc_unmon,
+		.p_decode	= (kxdrproc_t)xdr_dec_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
 		.p_statidx	= NSMPROC_UNMON,


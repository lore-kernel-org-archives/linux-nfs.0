From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/14] NLM: Decode "priv" argument of NLM_SM_NOTIFY as an
	opaque
Date: Fri, 24 Oct 2008 14:10:54 -0400
Message-ID: <20081024181054.23810.87257.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:14177 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbYJXSLV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:21 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m9OIBJGP008388
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:19 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9O1cDEu012282
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:13 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIAs1m023993
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:54 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NLM XDR decoders for the NLM_SM_NOTIFY procedure should treat
their "priv" argument truly as an opaque, as defined by the protocol,
and let the upper layers figure out what is in it.

This will make it easier to modify the contents and interpretation of
the "priv" argument, but for now NLM and NSM should behave exactly as
they did before.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c           |    3 ++-
 fs/lockd/xdr.c            |    4 ++--
 fs/lockd/xdr4.c           |    4 ++--
 include/linux/lockd/xdr.h |    8 ++++----
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 91e26be..4949eb3 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -501,9 +501,10 @@ void nlm_release_host(struct nlm_host *host)
  */
 void nlm_host_rebooted(struct nlm_reboot *info)
 {
+	__be32 *p = (__be32 *)&info->priv.data;
 	const struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= info->addr,
+		.sin_addr.s_addr	= *p,
 	};
 	struct hlist_head *chain;
 	struct hlist_node *pos;
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 1f22629..4cc7d01 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -349,8 +349,8 @@ nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
-	/* Preserve the address in network byte order */
-	argp->addr = *p++;
+	memcpy(&argp->priv.data, p, sizeof(argp->priv.data));
+	p += XDR_QUADLEN(SM_PRIV_SIZE);
 	return xdr_argsize_check(rqstp, p);
 }
 
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 50c493a..61d1714 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -356,8 +356,8 @@ nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp
 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
 		return 0;
 	argp->state = ntohl(*p++);
-	/* Preserve the address in network byte order */
-	argp->addr  = *p++;
+	memcpy(&argp->priv.data, p, sizeof(argp->priv.data));
+	p += XDR_QUADLEN(SM_PRIV_SIZE);
 	return xdr_argsize_check(rqstp, p);
 }
 
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index 6b51992..6338866 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -83,10 +83,10 @@ struct nlm_res {
  * statd callback when client has rebooted
  */
 struct nlm_reboot {
-	char *		mon;
-	unsigned int	len;
-	u32		state;
-	__be32		addr;
+	char			*mon;
+	unsigned int		len;
+	u32			state;
+	struct nsm_private	priv;
 };
 
 /*


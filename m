Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:61018 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757715Ab0LNPGz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:06:55 -0500
Received: by mail-gx0-f180.google.com with SMTP id 19so482684gxk.11
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:06:55 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/11] lockd: Remove src_sap and src_len from
	nlm_lookup_host_info struct
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:06:52 -0500
Message-ID: <20101214150652.2736.47968.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The contents of the src_sap field is not used in nlm_alloc_host().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 6d4aa8b..c106d6a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -53,8 +53,6 @@ struct nlm_lookup_host_info {
 	const u32		version;	/* NLM version to search for */
 	const char		*hostname;	/* remote's hostname */
 	const size_t		hostname_len;	/* it's length */
-	const struct sockaddr	*src_sap;	/* our address (optional) */
-	const size_t		src_len;	/* it's length */
 	const int		noresvport;	/* use non-priv port */
 };
 
@@ -324,6 +322,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	struct sockaddr_in6 sin6 = {
 		.sin6_family	= AF_INET6,
 	};
+	struct sockaddr *src_sap;
+	size_t src_len = rqstp->rq_addrlen;
 	struct nlm_lookup_host_info ni = {
 		.server		= 1,
 		.sap		= svc_addr(rqstp),
@@ -332,7 +332,6 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 		.version	= rqstp->rq_vers,
 		.hostname	= hostname,
 		.hostname_len	= hostname_len,
-		.src_len	= rqstp->rq_addrlen,
 	};
 
 	dprintk("lockd: %s(host='%*s', vers=%u, proto=%s)\n", __func__,
@@ -344,11 +343,11 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	switch (ni.sap->sa_family) {
 	case AF_INET:
 		sin.sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
-		ni.src_sap = (struct sockaddr *)&sin;
+		src_sap = (struct sockaddr *)&sin;
 		break;
 	case AF_INET6:
 		ipv6_addr_copy(&sin6.sin6_addr, &rqstp->rq_daddr.addr6);
-		ni.src_sap = (struct sockaddr *)&sin6;
+		src_sap = (struct sockaddr *)&sin6;
 		break;
 	default:
 		dprintk("lockd: %s failed; unrecognized address family\n",
@@ -372,7 +371,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 			continue;
 		if (host->h_version != ni.version)
 			continue;
-		if (!rpc_cmp_addr(nlm_srcaddr(host), ni.src_sap))
+		if (!rpc_cmp_addr(nlm_srcaddr(host), src_sap))
 			continue;
 
 		/* Move to head of hash chain. */
@@ -389,8 +388,8 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	if (unlikely(host == NULL))
 		goto out;
 
-	memcpy(nlm_srcaddr(host), ni.src_sap, ni.src_len);
-	host->h_srcaddrlen = ni.src_len;
+	memcpy(nlm_srcaddr(host), src_sap, src_len);
+	host->h_srcaddrlen = src_len;
 	hlist_add_head(&host->h_hash, chain);
 	nrhosts++;
 


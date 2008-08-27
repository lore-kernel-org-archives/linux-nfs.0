From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] lockd: Specify address family for source address
Date: Wed, 27 Aug 2008 16:57:31 -0400
Message-ID: <20080827205730.17837.78800.stgit@manray.1015granger.net>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59663 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYH0U6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 16:58:13 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure an address family is specified for source addresses passed to
nlm_lookup_host().  nlm_lookup_host() will need this when it becomes
capable of dealing with AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index e5dcfa5..22423ab 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -220,10 +220,12 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
 				     const char *hostname,
 				     unsigned int hostname_len)
 {
-	struct sockaddr_in ssin = {0};
+	const struct sockaddr_in source = {
+		.sin_family	= AF_UNSPEC,
+	};
 
 	return nlm_lookup_host(0, sin, proto, version,
-			       hostname, hostname_len, &ssin);
+			       hostname, hostname_len, &source);
 }
 
 /*
@@ -233,12 +235,14 @@ struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp,
 			const char *hostname, unsigned int hostname_len)
 {
-	struct sockaddr_in ssin = {0};
+	const struct sockaddr_in source = {
+		.sin_family	= AF_INET,
+		.sin_addr	= rqstp->rq_daddr.addr,
+	};
 
-	ssin.sin_addr = rqstp->rq_daddr.addr;
 	return nlm_lookup_host(1, svc_addr_in(rqstp),
 			       rqstp->rq_prot, rqstp->rq_vers,
-			       hostname, hostname_len, &ssin);
+			       hostname, hostname_len, &source);
 }
 
 /*


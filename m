From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/16] lockd: Specify address family for source address
Date: Mon, 30 Jun 2008 18:58:30 -0400
Message-ID: <20080630225829.25407.79346.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51808 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932650AbYF3XAf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 19:00:35 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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
index 350d757..618c631 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -215,10 +215,12 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
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
@@ -228,12 +230,14 @@ struct nlm_host *
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


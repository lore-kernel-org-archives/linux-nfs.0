From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/26] statd: Support IPv6 DNS lookups in smn_lookup
Date: Tue, 13 Oct 2009 10:56:56 -0400
Message-ID: <20091013145656.2424.15501.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:62322 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760125AbZJMO5k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:57:40 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEvKdj029709
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:21 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEv0OR021627
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:01 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When IPV6_SUPPORTED is enabled and the local system has IPv6 support,
request AF_INET6 and AF_INET addresses from the DNS resolver.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 443fd46..78b4174 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -73,10 +73,12 @@ static struct nsm_host *	hosts = NULL;
 static struct addrinfo *smn_lookup(const char *name)
 {
 	struct addrinfo	*ai, hint = {
-#if HAVE_DECL_AI_ADDRCONFIG
+#ifdef IPV6_SUPPORTED
 		.ai_flags	= AI_ADDRCONFIG,
-#endif	/* HAVE_DECL_AI_ADDRCONFIG */
+		.ai_family	= AF_UNSPEC,
+#else	/* !IPV6_SUPPORTED */
 		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
 		.ai_protocol	= IPPROTO_UDP,
 	};
 	int error;


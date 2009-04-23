From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/19] SUNRPC: Fix error return value of svc_addr_len()
Date: Thu, 23 Apr 2009 19:31:25 -0400
Message-ID: <20090423233124.17283.40252.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64760 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbZDWXcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:22 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The svc_addr_len() helper function returns -EAFNOSUPPORT if it doesn't
recognize the address family of the passed-in socket address.  However,
the return type of this function is size_t, which means -EAFNOSUPPORT
is turned into a very large positive value in this case.

The check in svc_udp_recvfrom() to see if the return value is less
than zero therefore won't work at all.

Additionally, handle_connect_req() passes this value directly to
memset().  This could cause memset() to clobber a large chunk of memory
if svc_addr_len() has returned an error.  Currently the address family
of these addresses, however, is known to be supported long before
handle_connect_req() is called, so this isn't a real risk.

Change the error return value of svc_addr_len() to zero, which fits in
the range of size_t, and is safer to pass to memset() directly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_xprt.h |    5 +++--
 net/sunrpc/svcsock.c            |    7 ++++---
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 0d9cb6e..d790c52 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -118,7 +118,7 @@ static inline unsigned short svc_addr_port(const struct sockaddr *sa)
 	return 0;
 }
 
-static inline size_t svc_addr_len(struct sockaddr *sa)
+static inline size_t svc_addr_len(const struct sockaddr *sa)
 {
 	switch (sa->sa_family) {
 	case AF_INET:
@@ -126,7 +126,8 @@ static inline size_t svc_addr_len(struct sockaddr *sa)
 	case AF_INET6:
 		return sizeof(struct sockaddr_in6);
 	}
-	return -EAFNOSUPPORT;
+
+	return 0;
 }
 
 static inline unsigned short svc_xprt_local_port(const struct svc_xprt *xprt)
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index af31988..8b08328 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -426,13 +426,14 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		long		all[SVC_PKTINFO_SPACE / sizeof(long)];
 	} buffer;
 	struct cmsghdr *cmh = &buffer.hdr;
-	int		err, len;
 	struct msghdr msg = {
 		.msg_name = svc_addr(rqstp),
 		.msg_control = cmh,
 		.msg_controllen = sizeof(buffer),
 		.msg_flags = MSG_DONTWAIT,
 	};
+	size_t len;
+	int err;
 
 	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
 	    /* udp sockets need large rcvbuf as all pending
@@ -464,8 +465,8 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		return -EAGAIN;
 	}
 	len = svc_addr_len(svc_addr(rqstp));
-	if (len < 0)
-		return len;
+	if (len == 0)
+		return -EAFNOSUPPORT;
 	rqstp->rq_addrlen = len;
 	if (skb->tstamp.tv64 == 0) {
 		skb->tstamp = ktime_get_real();


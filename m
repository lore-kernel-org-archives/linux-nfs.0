From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/6] nfs-utils: add IPv6 code to gssd
Date: Wed, 11 Mar 2009 12:43:02 -0400
Message-ID: <1236789782-8867-7-git-send-email-jlayton@redhat.com>
References: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
Cc: kwc@citi.umich.edu, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32909 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088AbZCKQnR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 12:43:17 -0400
In-Reply-To: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All of the pieces to handle IPv6 are now in place. Add IPv6-specific
code wrapped in the proper #ifdef's so that IPv6 support works when
it's enabled at build-time.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1e3dabc..ad66d33 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -110,6 +110,7 @@ addrstr_to_sockaddr(const char *addr, const int port)
 {
 	struct sockaddr_storage *ss;
 	struct sockaddr_in	*s4;
+	struct sockaddr_in6	*s6;
 
 	ss = calloc(1, sizeof(struct sockaddr_storage));
 	if (!ss) {
@@ -119,10 +120,16 @@ addrstr_to_sockaddr(const char *addr, const int port)
 	}
 
 	s4 = (struct sockaddr_in *) ss;
+	s6 = (struct sockaddr_in6 *) ss;
 
 	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
 		s4->sin_family = AF_INET;
 		s4->sin_port = htons(port);
+#ifdef IPV6_SUPPORTED
+	} else if (inet_pton(AF_INET6, addr, &s6->sin6_addr)) {
+		s6->sin6_family = AF_INET6;
+		s6->sin6_port = htons(port);
+#endif /* IPV6_SUPPORTED */
 	} else {
 		printerr(0, "ERROR: unable to convert %s to address\n", addr);
 		free(ss);
@@ -147,6 +154,11 @@ sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
 	case AF_INET:
 		addrlen = sizeof(struct sockaddr_in);
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		addrlen = sizeof(struct sockaddr_in6);
+		break;
+#endif /* IPV6_SUPPORTED */
 	default:
 		printerr(0, "ERROR: unrecognized addr family %d\n",
 			 sa->sa_family);
@@ -578,6 +590,12 @@ create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
 		nc_protofmly = NC_INET;
 		nb.len = nb.maxlen = sizeof(struct sockaddr_in);
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		nc_protofmly = NC_INET6;
+		nb.len = nb.maxlen = sizeof(struct sockaddr_in6);
+		break;
+#endif /* IPV6_SUPPORTED */
 	default:
 		printerr(0, "ERROR: unsupported address family %d\n",
 			    clp->addr->ss_family);
@@ -684,6 +702,7 @@ populate_port(struct sockaddr_storage *ss, char *servicename, int socktype,
 	      int protocol)
 {
 	struct sockaddr_in	*s4 = (struct sockaddr_in *) ss;
+	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) ss;
 	struct addrinfo		ai_hints, *a = NULL;
 	char			node[INET_ADDRSTRLEN];
 	char			service[64];
@@ -703,6 +722,18 @@ populate_port(struct sockaddr_storage *ss, char *servicename, int socktype,
 				sizeof(struct sockaddr_in)))
 			return 0;
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		if (s6->sin6_port != 0) {
+			printerr(2, "DEBUG: port already set to %d\n",
+				 ntohs(s6->sin6_port));
+			return 1;
+		}
+		if (!inet_ntop(AF_INET6, &s6->sin6_addr, node,
+				sizeof(struct sockaddr_in6)))
+			return 0;
+		break;
+#endif /* IPV6_SUPPORTED */
 	default:
 		printerr(0, "ERROR: unsupported address family %d\n",
 			    ss->ss_family);
@@ -738,6 +769,10 @@ populate_port(struct sockaddr_storage *ss, char *servicename, int socktype,
 	/* XXX: walk all of the returned addrinfo list until we get port? */
 	if (a->ai_family == AF_INET) {
 		s4->sin_port = ((struct sockaddr_in *) a->ai_addr)->sin_port;
+#ifdef IPV6_SUPPORTED
+	} else if (a->ai_family == AF_INET6) {
+		s6->sin6_port = ((struct sockaddr_in6 *) a->ai_addr)->sin6_port;
+#endif /* IPV6_SUPPORTED */
 	} else {
 		printerr(0, "ERROR: unrecognized address family returned by "
 			 "getaddrinfo %d\n", a->ai_family,
-- 
1.6.0.6


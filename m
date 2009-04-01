From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/6] nfs-utils: add IPv6 code to gssd
Date: Wed,  1 Apr 2009 10:24:05 -0400
Message-ID: <1238595845-2186-7-git-send-email-jlayton@redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, kwc@citi.umich.edu
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:50562 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765853AbZDAOYM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 10:24:12 -0400
In-Reply-To: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All of the pieces to handle IPv6 are now in place. Add IPv6-specific
code wrapped in the proper #ifdef's so that IPv6 support works when
it's enabled at build-time.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 2d7b58d..93908a3 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -110,10 +110,16 @@ static int
 addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const int port)
 {
 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
+	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
 
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
 		return 0;
@@ -137,6 +143,11 @@ sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
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
@@ -564,6 +575,12 @@ create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
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
 		printerr(0, "ERROR: unsupported address family %hd\n", af);
 		goto out;
@@ -669,6 +686,7 @@ populate_port(struct sockaddr *sa, char *servicename, int socktype,
 	      int protocol)
 {
 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
+	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
 	char			node[INET_ADDRSTRLEN];
 	char			service[64];
 	char			*at_sign;
@@ -690,6 +708,18 @@ populate_port(struct sockaddr *sa, char *servicename, int socktype,
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
 			    sa->sa_family);
@@ -721,6 +751,10 @@ populate_port(struct sockaddr *sa, char *servicename, int socktype,
 
 	if (a->ai_family == AF_INET)
 		s4->sin_port = ((struct sockaddr_in *) a->ai_addr)->sin_port;
+#ifdef IPV6_SUPPORTED
+	else if (a->ai_family == AF_INET6)
+		s6->sin6_port = ((struct sockaddr_in6 *) a->ai_addr)->sin6_port;
+#endif /* IPV6_SUPPORTED */
 	else
 		printerr(0, "ERROR: unrecognized address family %d returned "
 			    "by getaddrinfo.\n", a->ai_family);
-- 
1.6.0.6


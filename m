From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/5] nfs-utils: add IPv6 code to gssd
Date: Tue,  7 Apr 2009 11:25:46 -0400
Message-ID: <1239117946-7535-6-git-send-email-jlayton@redhat.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

All of the pieces to handle IPv6 are now in place. Add IPv6-specific
code wrapped in the proper #ifdef's so that IPv6 support works when
it's enabled at build-time.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 5b97d6c..70094cf 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -106,15 +106,32 @@ int pollsize;  /* the size of pollaray (in pollfd's) */
 /*
  * convert a presentation address string to a sockaddr_storage struct. Returns
  * true on success and false on failure.
+ *
+ * Note that we do not populate the sin6_scope_id field here for IPv6 addrs.
+ * gssd nececessarily relies on hostname resolution and DNS AAAA records
+ * do not generally contain scope-id's. This means that GSSAPI auth really
+ * can't work with IPv6 link-local addresses.
+ *
+ * We *could* consider changing this if we did something like adopt the
+ * Microsoft "standard" of using the ipv6-literal.net domainname, but it's
+ * not really feasible at present.
  */
 static int
 addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const int port)
 {
 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
+#ifdef IPV6_SUPPORTED
+	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
+#endif /* IPV6_SUPPORTED */
 
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
@@ -138,6 +155,11 @@ sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
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
@@ -553,6 +575,9 @@ populate_port(struct sockaddr *sa, const socklen_t salen,
 	      const unsigned short protocol)
 {
 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
+#ifdef IPV6_SUPPORTED
+	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
+#endif /* IPV6_SUPPORTED */
 	unsigned short		port;
 
 	/*
@@ -567,6 +592,15 @@ populate_port(struct sockaddr *sa, const socklen_t salen,
 			return 1;
 		}
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		if (s6->sin6_port != 0) {
+			printerr(2, "DEBUG: port already set to %d\n",
+				 ntohs(s6->sin6_port));
+			return 1;
+		}
+		break;
+#endif /* IPV6_SUPPORTED */
 	default:
 		printerr(0, "ERROR: unsupported address family %d\n",
 			    sa->sa_family);
@@ -594,6 +628,11 @@ set_port:
 	case AF_INET:
 		s4->sin_port = htons(port);
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		s6->sin6_port = htons(port);
+		break;
+#endif /* IPV6_SUPPORTED */
 	}
 
 	return 1;
@@ -688,6 +727,11 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	case AF_INET:
 		salen = sizeof(struct sockaddr_in);
 		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		salen = sizeof(struct sockaddr_in6);
+		break;
+#endif /* IPV6_SUPPORTED */
 	default:
 		printerr(1, "ERROR: Unknown address family %d\n",
 			 addr->sa_family);
-- 
1.6.0.6

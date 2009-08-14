From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/6] sunrpc: add common routine for copying address portion of
	a sockaddr
Date: Fri, 14 Aug 2009 12:57:55 -0400
Message-ID: <1250269079-14629-3-git-send-email-jlayton@redhat.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org, chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/clnt.h |   50 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b17df36..044f531 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -198,6 +198,17 @@ static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
 	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
 }
 
+static inline bool __rpc_copy_addr4(struct sockaddr *dst,
+				    const struct sockaddr *src)
+{
+	const struct sockaddr_in *ssin = (struct sockaddr_in *) src;
+	struct sockaddr_in *dsin = (struct sockaddr_in *) dst;
+
+	dsin->sin_family = ssin->sin_family;
+	dsin->sin_addr.s_addr = ssin->sin_addr.s_addr;
+	return true;
+}
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
 				   const struct sockaddr *sap2)
@@ -206,12 +217,29 @@ static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
 	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
 }
+
+static inline bool __rpc_copy_addr6(struct sockaddr *dst,
+				    const struct sockaddr *src)
+{
+	const struct sockaddr_in6 *ssin6 = (const struct sockaddr_in6 *) src;
+	struct sockaddr_in6 *dsin6 = (struct sockaddr_in6 *) dst;
+
+	dsin6->sin6_family = ssin6->sin6_family;
+	ipv6_addr_copy(&dsin6->sin6_addr, &ssin6->sin6_addr);
+	return true;
+}
 #else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
 static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
 				   const struct sockaddr *sap2)
 {
 	return false;
 }
+
+static inline bool __rpc_copy_addr6(struct sockaddr *dst,
+				    const struct sockaddr *src)
+{
+	return false;
+}
 #endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
 
 /**
@@ -236,5 +264,27 @@ static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
 	return false;
 }
 
+/**
+ * rpc_copy_addr - copy the address portion of one sockaddr to another
+ * @dst: destination sockaddr
+ * @src: source sockaddr
+ *
+ * Just copies the address portion and family. Ignores port, scope, etc.
+ * Caller is responsible for making certain that dst is large enough to hold
+ * the address in src. Returns true if address family is supported. Returns
+ * false otherwise.
+ */
+static inline bool rpc_copy_addr(struct sockaddr *dst,
+				 const struct sockaddr *src)
+{
+	switch (src->sa_family) {
+	case AF_INET:
+		return __rpc_copy_addr4(dst, src);
+	case AF_INET6:
+		return __rpc_copy_addr6(dst, src);
+	}
+	return false;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
-- 
1.6.0.6

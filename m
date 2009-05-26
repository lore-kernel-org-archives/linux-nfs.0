From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/6] nfs-utils: limit protocols and families used by nfsd to those listed in /etc/netconfig
Date: Tue, 26 May 2009 11:15:50 -0400
Message-ID: <1243350951-13462-6-git-send-email-jlayton@redhat.com>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46740 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbZEZPP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 11:15:58 -0400
In-Reply-To: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...disable any that aren't listed or aren't marked as "visible".

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfslib.h |    2 +
 support/nfs/nfssvc.c     |   69 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsd/nfsd.c        |   33 +++++++++++++++------
 3 files changed, 94 insertions(+), 10 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 0bfb2ee..7871ac1 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -131,6 +131,8 @@ int			wildmat(char *text, char *pattern);
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
 int			nfssvc_inuse(void);
+unsigned int		nfssvc_set_family_proto(const sa_family_t family,
+						unsigned int ctlbits);
 void			nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa,
 					socklen_t addrlen);
 void			nfssvc_setvers(unsigned int ctlbits, int minorvers4);
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index b14d37d..e5b52f2 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -18,8 +18,13 @@
 #include <errno.h>
 #include <syslog.h>
 
+#ifdef HAVE_LIBTIRPC
+#include <netdb.h>
+#include <netconfig.h>
+#endif
 
 #include "nfslib.h"
+#include "nfsrpc.h"
 
 #define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
 #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
@@ -54,6 +59,70 @@ nfssvc_inuse(void)
 	return 0;
 }
 
+#ifdef HAVE_LIBTIRPC
+static unsigned int
+nfssvc_netid_visible(const sa_family_t family, const unsigned short protocol)
+{
+	char *nc_protofmly, *nc_proto;
+	struct netconfig *nconf;
+	struct protoent *proto;
+	void *handle;
+
+	switch (family) {
+	case AF_LOCAL:
+	case AF_INET:
+		nc_protofmly = NC_INET;
+		break;
+	case AF_INET6:
+		nc_protofmly = NC_INET6;
+		break;
+	default:
+		return 0;
+	}
+
+	proto = getprotobynumber(protocol);
+	if (proto == NULL)
+		return 0;
+	nc_proto = proto->p_name;
+
+	handle = setnetconfig();
+	while((nconf = getnetconfig(handle))) {
+		if (!(nconf->nc_flag & NC_VISIBLE))
+			continue;
+		if (nconf->nc_protofmly &&
+		    strcmp(nconf->nc_protofmly, nc_protofmly))
+			continue;
+		if (nconf->nc_proto && strcmp(nconf->nc_proto, nc_proto))
+			continue;
+		endnetconfig(handle);
+		return 1;
+	}
+	endnetconfig(handle);
+	return 0;
+}
+#else
+static unsigned int
+nfssvc_netid_visible(const sa_family_t family, const unsigned short protocol)
+{
+	return 1;
+}
+#endif
+
+/* given a family and ctlbits, disable any that aren't listed in netconfig */
+unsigned int
+nfssvc_set_family_proto(const sa_family_t family, unsigned int ctlbits)
+{
+	if (NFSCTL_UDPISSET(ctlbits) &&
+	    !nfssvc_netid_visible(family, IPPROTO_UDP))
+		NFSCTL_UDPUNSET(ctlbits);
+
+	if (NFSCTL_TCPISSET(ctlbits) &&
+	    !nfssvc_netid_visible(family, IPPROTO_TCP))
+		NFSCTL_TCPUNSET(ctlbits);
+
+	return ctlbits;
+}
+
 void
 nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 {
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 29611d4..578fcbe 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -54,6 +54,8 @@ main(int argc, char **argv)
 	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
 	char	*haddr = NULL;
 	int	ipv4 = 1;
+	unsigned int proto4;
+	unsigned int proto6;
 #ifdef IPV6_SUPPORTED
 	int	ipv6 = 1;
 #else  /* IPV6_SUPPORTED */
@@ -165,15 +167,25 @@ main(int argc, char **argv)
 	}
 
 family_check:
-	/* make sure at least one address family is enabled */
-	if (!ipv4 && !ipv6) {
-		fprintf(stderr, "no address families enabled\n");
-		exit(1);
+	/* limit protocols to use based on /etc/netconfig */
+	proto4 = nfssvc_set_family_proto(AF_INET, protobits);
+	proto6 = nfssvc_set_family_proto(AF_INET6, protobits);
+
+	/* make sure at least one protocol type is enabled */
+	if (ipv4 && !NFSCTL_UDPISSET(proto4) && !NFSCTL_TCPISSET(proto4)) {
+		fprintf(stderr, "WARNING: no protocols enabled for IPv4\n");
+		ipv4 = 0;
 	}
 
 	/* make sure at least one protocol type is enabled */
-	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
-		fprintf(stderr, "invalid protocol specified\n");
+	if (ipv6 && !NFSCTL_UDPISSET(proto6) && !NFSCTL_TCPISSET(proto6)) {
+		fprintf(stderr, "WARNING: no protocols enabled for IPv6\n");
+		ipv6 = 0;
+	}
+
+	/* make sure at least one address family is enabled */
+	if (!ipv4 && !ipv6) {
+		fprintf(stderr, "no address families enabled\n");
 		exit(1);
 	}
 
@@ -189,7 +201,9 @@ family_check:
 	}			
 
 	/* must have TCP for NFSv4 */
-	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
+	if (NFSCTL_VERISSET(versbits, 4) &&
+	    !NFSCTL_TCPISSET(proto4) &&
+	    !NFSCTL_TCPISSET(proto6)) {
 		fprintf(stderr, "version 4 requires the TCP protocol\n");
 		exit(1);
 	}
@@ -250,7 +264,7 @@ family_check:
 		if (!haddr)
 			sin.sin_addr.s_addr = INADDR_ANY;
 
-		nfssvc_setfds(protobits, (struct sockaddr *) &sin, sizeof(sin));
+		nfssvc_setfds(proto4, (struct sockaddr *) &sin, sizeof(sin));
 	}
 
 #ifdef IPV6_SUPPORTED
@@ -260,8 +274,7 @@ family_check:
 		if (!haddr)
 			sin6.sin6_addr = in6addr_any;
 
-		nfssvc_setfds(protobits, (struct sockaddr *) &sin6,
-				sizeof(sin6));
+		nfssvc_setfds(proto6, (struct sockaddr *) &sin6, sizeof(sin6));
 	}
 #endif /* IPV6_SUPPORTED */
 
-- 
1.6.0.6


From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/5] nfs-utils: limit protocols and families used by nfsd to those listed in /etc/netconfig
Date: Wed, 27 May 2009 07:54:35 -0400
Message-ID: <1243425275-6284-6-git-send-email-jlayton@redhat.com>
References: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40506 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760004AbZE0Lyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2009 07:54:41 -0400
In-Reply-To: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...disable any that aren't listed or aren't marked as "visible".

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfslib.h |    2 +
 support/nfs/nfssvc.c     |   69 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsd/nfsd.c        |   32 +++++++++++++++------
 3 files changed, 94 insertions(+), 9 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 4cb1dc0..bae0902 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -133,6 +133,8 @@ int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
 int			nfssvc_inuse(void);
 int			nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa,
 					socklen_t addrlen);
+unsigned int		nfssvc_set_family_proto(const sa_family_t family,
+						unsigned int ctlbits);
 void			nfssvc_setvers(unsigned int ctlbits, int minorvers4);
 int			nfssvc_threads(unsigned short port, int nrservs);
 int			nfsaddclient(struct nfsctl_client *clp);
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 2aa5281..a91c892 100644
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
 int
 nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
 {
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 77c7e1b..45bede9 100644
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
@@ -159,15 +161,25 @@ main(int argc, char **argv)
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
 
@@ -183,7 +195,9 @@ family_check:
 	}			
 
 	/* must have TCP for NFSv4 */
-	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
+	if (NFSCTL_VERISSET(versbits, 4) &&
+	    !NFSCTL_TCPISSET(proto4) &&
+	    !NFSCTL_TCPISSET(proto6)) {
 		fprintf(stderr, "version 4 requires the TCP protocol\n");
 		exit(1);
 	}
@@ -244,7 +258,7 @@ family_check:
 		if (!haddr)
 			sin.sin_addr.s_addr = INADDR_ANY;
 
-		if (nfssvc_setfds(protobits, (struct sockaddr *) &sin, sizeof(sin)))
+		if (nfssvc_setfds(proto4, (struct sockaddr *) &sin, sizeof(sin)))
 			ipv4 = 0;
 	}
 
@@ -255,7 +269,7 @@ family_check:
 		if (!haddr)
 			sin6.sin6_addr = in6addr_any;
 
-		if (nfssvc_setfds(protobits, (struct sockaddr *) &sin6, sizeof(sin6)))
+		if (nfssvc_setfds(proto6, (struct sockaddr *) &sin6, sizeof(sin6)))
 			ipv6 = 0;
 	}
 #endif /* IPV6_SUPPORTED */
-- 
1.6.0.6


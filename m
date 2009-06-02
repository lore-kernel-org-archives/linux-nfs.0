From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/6] nfs-utils: add IPv6 support to nfsd
Date: Tue,  2 Jun 2009 07:43:48 -0400
Message-ID: <1243943029-6400-6-git-send-email-jlayton@redhat.com>
References: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42916 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760350AbZFBLoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 07:44:01 -0400
In-Reply-To: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for handing off IPv6 sockets to the kernel for nfsd. One of
the main goals here is to not change the behavior of options and not to
add any new ones, so this patch attempts to do that.

We also don't want to break anything in the event that someone has an
rpc.nfsd program built with IPv6 capability, but the knfsd doesn't
support IPv6. Ditto for the cases where IPv6 is either not compiled in
or is compiled in and blacklisted.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfs/nfs.h |   15 +++-
 utils/nfsd/nfsd.c         |  170 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 141 insertions(+), 44 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 00b0028..a64eb0a 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -42,14 +42,21 @@ struct nfs_fh_old {
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define NFSCTL_GETFS		8	/* get an fh by path with max size (used by mountd) */
 
+#define NFSCTL_UDPBIT		      (1 << (17 - 1))
+#define NFSCTL_TCPBIT		      (1 << (18 - 1))
+
 #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
-#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1))) 
-#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1))) 
+#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_UDPBIT) 
+#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_TCPBIT) 
 
 #define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
-#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & (1 << (17 - 1))) 
-#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & (1 << (18 - 1))) 
+#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
+#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
+
+#define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
+#define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
 
+#define NFSCTL_ANYPROTO(_cltbits)     ((_cltbits) & (NFSCTL_UDPBIT | NFSCTL_TCPBIT))
 #define NFSCTL_ALLBITS (~0)
 
 /* SVC */
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index bdc71db..efacd12 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -40,17 +40,82 @@ static struct option longopts[] =
 	{ "debug", 0, 0, 'd' },
 	{ NULL, 0, 0, 0 }
 };
-unsigned int protobits = NFSCTL_ALLBITS;
-unsigned int versbits = NFSCTL_ALLBITS;
-int minorvers4 = NFSD_MAXMINORVERS4;		/* nfsv4 minor version */
+
+/* given a family and ctlbits, disable any that aren't listed in netconfig */
+#ifdef HAVE_LIBTIRPC
+static void
+nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
+{
+	struct netconfig *nconf;
+	unsigned int *famproto;
+	void *handle;
+
+	xlog(D_GENERAL, "Checking netconfig for visible protocols.");
+
+	handle = setnetconfig();
+	while((nconf = getnetconfig(handle))) {
+		if (!(nconf->nc_flag & NC_VISIBLE))
+			continue;
+
+		if (!strcmp(nconf->nc_protofmly, NC_INET))
+			famproto = proto4;
+		else if (!strcmp(nconf->nc_protofmly, NC_INET6))
+			famproto = proto6;
+		else
+			continue;
+
+		if (!strcmp(nconf->nc_proto, NC_TCP))
+			NFSCTL_TCPSET(*famproto);
+		else if (!strcmp(nconf->nc_proto, NC_UDP))
+			NFSCTL_UDPSET(*famproto);
+
+		xlog(D_GENERAL, "Enabling %s %s.", nconf->nc_protofmly,
+			nconf->nc_proto);
+	}
+	endnetconfig(handle);
+	return;
+}
+#else /* HAVE_LIBTIRPC */
+static void
+nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
+{
+	/* Enable all IPv4 protocols if no TIRPC support */
+	*proto4 = NFSCTL_ALLBITS;
+	*proto6 = 0;
+}
+#endif /* HAVE_LIBTIRPC */
+
+/* returns 1 on success, 0 on failure */
+static int
+nfsd_set_socket(const int family, const unsigned int protobits,
+		const char *host, const char *port)
+{
+	struct addrinfo hints = { .ai_flags = AI_PASSIVE | AI_ADDRCONFIG };
+
+	hints.ai_family = family;
+
+	if (!NFSCTL_ANYPROTO(protobits))
+		return 0;
+	else if (!NFSCTL_UDPISSET(protobits))
+		hints.ai_protocol = IPPROTO_TCP;
+	else if (!NFSCTL_TCPISSET(protobits))
+		hints.ai_protocol = IPPROTO_UDP;
+
+	return nfssvc_setfds(&hints, host, port) ? 0 : 1;
+}
 
 int
 main(int argc, char **argv)
 {
-	int	count = 1, c, error, portnum = 0, fd, found_one;
+	int	count = 1, c, error = 0, portnum = 0, fd, found_one;
 	char *p, *port = "nfs";
 	char *haddr = NULL;
-	struct addrinfo hints = { .ai_flags = AI_PASSIVE | AI_ADDRCONFIG };
+	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
+	unsigned int versbits = NFSCTL_ALLBITS;
+	unsigned int protobits = NFSCTL_ALLBITS;
+	unsigned int proto4 = 0;
+	unsigned int proto6 = 0;
+	int socket_up = 0;
 
 	xlog_syslog(1);
 	xlog_stderr(0);
@@ -109,8 +174,38 @@ main(int argc, char **argv)
 		}
 	}
 
+	if (optind < argc) {
+		if ((count = atoi(argv[optind])) < 0) {
+			/* insane # of servers */
+			fprintf(stderr,
+				"%s: invalid server count (%d), using 1\n",
+				argv[0], count);
+			count = 1;
+		} else if (count == 0) {
+			/*
+			 * don't bother setting anything else if the threads
+			 * are coming down anyway.
+			 */
+			socket_up = 1;
+			goto set_threads;
+		}
+	}
+
 	xlog_open("nfsd");
 
+	nfsd_enable_protos(&proto4, &proto6);
+
+	if (!NFSCTL_TCPISSET(protobits)) {
+		NFSCTL_TCPUNSET(proto4);
+		NFSCTL_TCPUNSET(proto6);
+	}
+
+	if (!NFSCTL_UDPISSET(protobits)) {
+		NFSCTL_UDPUNSET(proto4);
+		NFSCTL_UDPUNSET(proto6);
+	}
+
+	/* make sure that at least one version is enabled */
 	found_one = 0;
 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
 		if (NFSCTL_VERISSET(versbits, c))
@@ -121,14 +216,12 @@ main(int argc, char **argv)
 		exit(1);
 	}			
 
-	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
+	if (NFSCTL_VERISSET(versbits, 4) &&
+	    !NFSCTL_TCPISSET(proto4) &&
+	    !NFSCTL_TCPISSET(proto6)) {
 		xlog(L_ERROR, "version 4 requires the TCP protocol");
 		exit(1);
 	}
-	if (haddr == NULL) {
-		struct in_addr in = {INADDR_ANY}; 
-		haddr = strdup(inet_ntoa(in));
-	}
 
 	if (chdir(NFS_STATEDIR)) {
 		xlog(L_ERROR, "chdir(%s) failed: %s",
@@ -136,49 +229,46 @@ main(int argc, char **argv)
 		exit(1);
 	}
 
-	if (optind < argc) {
-		if ((count = atoi(argv[optind])) < 0) {
-			/* insane # of servers */
-			xlog(L_ERROR,
-				"invalid server count (%d), using 1",
-				argv[0], count);
-			count = 1;
-		}
+	/* we can only change number of threads if nfsd is already up */
+	if (nfssvc_inuse()) {
+		socket_up = 1;
+		goto set_threads;
 	}
 
-	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
-		xlog(L_ERROR, "invalid protocol specified");
-		exit(1);
-	}
-
-	if (!NFSCTL_UDPISSET(protobits))
-		hints.ai_protocol = IPPROTO_TCP;
-	else if (!NFSCTL_TCPISSET(protobits))
-		hints.ai_protocol = IPPROTO_UDP;
-
-	hints.ai_family = AF_INET;
-
 	/*
 	 * must set versions before the fd's so that the right versions get
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
 	 */
-	if (!nfssvc_inuse()) {
-		nfssvc_setvers(versbits, minorvers4);
-		error = nfssvc_setfds(&hints, haddr, port);
-		if (error)
-			goto out;
+	nfssvc_setvers(versbits, minorvers4);
+ 
+	if (nfsd_set_socket(AF_INET, proto4, haddr, port))
+		socket_up = 1;
+
+#ifdef IPV6_SUPPORTED
+	if (nfsd_set_socket(AF_INET6, proto6, haddr, port))
+		socket_up = 1;
+#endif /* IPV6_SUPPORTED */
+
+set_threads:
+	/* don't start any threads if unable to hand off any sockets */
+	if (!socket_up) {
+		xlog(L_ERROR, "unable to set any sockets for nfsd");
+		goto out;
 	}
+	error = 0;
 
-	/* KLUDGE ALERT:
-	   Some kernels let nfsd kernel threads inherit open files
-	   from the program that spawns them (i.e. us).  So close
-	   everything before spawning kernel threads.  --Chip */
+	/*
+	 * KLUDGE ALERT:
+	 * Some kernels let nfsd kernel threads inherit open files
+	 * from the program that spawns them (i.e. us).  So close
+	 * everything before spawning kernel threads.  --Chip
+	 */
 	xlog_syslog(1);
 	xlog_stderr(0);
 	fd = open("/dev/null", O_RDWR);
 	if (fd == -1)
-		perror("/dev/null");
+		xlog(L_ERROR, "unable to open /dev/null: %s", strerror(errno));
 	else {
 		(void) dup2(fd, 0);
 		(void) dup2(fd, 1);
-- 
1.6.0.6


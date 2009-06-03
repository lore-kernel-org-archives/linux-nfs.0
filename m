From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 09/10] nfs-utils: add IPv6 support to nfsd
Date: Wed,  3 Jun 2009 15:52:42 -0400
Message-ID: <1244058763-10352-10-git-send-email-jlayton@redhat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51460 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbZFCTwv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:52:51 -0400
In-Reply-To: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
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
 utils/nfsd/nfsd.c |  114 +++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 89 insertions(+), 25 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 012847b..8d753f2 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -40,17 +40,63 @@ static struct option longopts[] =
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
 
 int
 main(int argc, char **argv)
 {
-	int	count = 1, c, error, portnum = 0, fd, found_one;
+	int	count = 1, c, error = 0, portnum = 0, fd, found_one;
 	char *p, *progname, *port;
 	char *haddr = NULL;
 	int	socket_up = 0;
+	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
+	unsigned int versbits = NFSCTL_ALLBITS;
+	unsigned int protobits = NFSCTL_ALLBITS;
+	unsigned int proto4 = 0;
+	unsigned int proto6 = 0;
 
 	progname = strdup(basename(argv[0]));
 	if (!progname) {
@@ -133,15 +179,38 @@ main(int argc, char **argv)
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
 	xlog_open(progname);
 
-	/*
-	 * Do some sanity checking, if the ctlbits are set
-	 */
-	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
-		xlog(L_ERROR, "invalid protocol specified");
-		exit(1);
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
 	}
+
+	/* make sure that at least one version is enabled */
 	found_one = 0;
 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
 		if (NFSCTL_VERISSET(versbits, c))
@@ -152,29 +221,18 @@ main(int argc, char **argv)
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
 		xlog(L_ERROR, "chdir(%s) failed: %m", NFS_STATEDIR);
 		exit(1);
 	}
 
-	if (optind < argc) {
-		if ((count = atoi(argv[optind])) < 0) {
-			/* insane # of servers */
-			xlog(L_ERROR, "invalid server count (%d), using 1",
-				      count);
-			count = 1;
-		}
-	}
-
 	/* can only change number of threads if nfsd is already up */
 	if (nfssvc_inuse()) {
 		socket_up = 1;
@@ -187,10 +245,16 @@ main(int argc, char **argv)
 	 * interfaces, these are a no-op.
 	 */
 	nfssvc_setvers(versbits, minorvers4);
+ 
+	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
+	if (!error)
+		socket_up = 1;
 
-	error = nfssvc_set_sockets(AF_INET, protobits, haddr, port);
+#ifdef IPV6_SUPPORTED
+	error = nfssvc_set_sockets(AF_INET6, proto6, haddr, port);
 	if (!error)
 		socket_up = 1;
+#endif /* IPV6_SUPPORTED */
 
 set_threads:
 	/* don't start any threads if unable to hand off any sockets */
-- 
1.6.2.2


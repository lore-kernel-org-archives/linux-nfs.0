From: Ian Kent <raven@themaw.net>
Subject: [RFC:PATCH] nfs-utils - showmount RPC timeout handling
Date: Tue, 19 Dec 2006 12:42:37 +0900
Message-ID: <1166499757.3482.40.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwVs9-0006kQ-SC
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 19:42:34 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwVsA-00007r-SU
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 19:42:35 -0800
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Hi all,

I've been doing some work on showmount to try and work out why it can
take a long time to return when a non-existent server is specified.

>From what I can see showmount itself tries to use a short timeout but
the RPC clnttcp_create and clntudp_create calls will call portmap
internally to get the port to use if it is set to 0 in the passed
address structure. The above calls then use the internal timeouts,
basically 60 seconds, which slows things down. Also the for tcp a
blocking connect is used which can take quite a while to timeout as
well.

showmount tries tcp then udp so a fail can go through several lengthy
waits before failing.

Another thing I noticed in showmount is that RPC procedure calls don't
use a call to the service null procedure before performing the call
itself. This is not required but can sometimes return a fail somewhat
more quickly than just going ahead and calling the procedure entry point
straight away.

I've grabbed some of the autofs code and put together a patch to allow
specification of the timeouts for the portmap getport and to implement a
non-blocking connect.

I'd like feedback on the patch as to it's suitability for inclusion in
nfs-utils or what other work may be needed and mistakes that I may have
made.

Ian

---
--- nfs-utils-1.0.8/utils/showmount/showmount.c.reduce-timeout	2005-12-20 12:12:47.000000000 +0800
+++ nfs-utils-1.0.8/utils/showmount/showmount.c	2006-12-15 21:35:20.000000000 +0800
@@ -19,6 +19,7 @@
 
 #include <stdio.h>
 #include <rpc/rpc.h>
+#include <rpc/pmap_prot.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <sys/time.h>
@@ -27,6 +28,7 @@
 #include <unistd.h>
 #include <memory.h>
 #include <stdlib.h>
+#include <fcntl.h>
 
 #include <netdb.h>
 #include <arpa/inet.h>
@@ -35,6 +37,10 @@
 #include <mount.h>
 #include <unistd.h>
 
+#define TOUT_UDP	3
+#define TOUT_TCP	10
+#define TOT_TOUT	20
+
 static char *	version = "showmount for " VERSION;
 static char *	program_name;
 static int	headers = 1;
@@ -73,6 +79,180 @@
 	exit(n);
 }
 
+/*
+ *  Perform a non-blocking connect on the socket fd.
+ *
+ *  tout contains the timeout.  It will be modified to contain the time
+ *  remaining (i.e. time provided - time elasped).
+ */
+static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval *tout)
+{
+	int flags, ret;
+	socklen_t len;
+	fd_set wset, rset;
+
+	flags = fcntl(fd, F_GETFL, 0);
+	if (flags < 0)
+		return -1;
+
+	ret = fcntl(fd, F_SETFL, flags | O_NONBLOCK);
+	if (ret < 0)
+		return -1;
+
+	/*
+	 * From here on subsequent sys calls could change errno so
+	 * we set ret = -errno to capture it in case we decide to
+	 * use it later.
+	 */
+	len = sizeof(struct sockaddr);
+	ret = connect(fd, (struct sockaddr *)addr, len);
+	if (ret < 0 && errno != EINPROGRESS) {
+		ret = -errno;
+		goto done;
+	}
+
+	if (ret == 0)
+		goto done;
+
+	/* now wait */
+	FD_ZERO(&rset);
+	FD_SET(fd, &rset);
+	wset = rset;
+
+	ret = select(fd + 1, &rset, &wset, NULL, tout);
+	if (ret <= 0) {
+		if (ret == 0)
+			ret = -ETIMEDOUT;
+		else
+			ret = -errno;
+		goto done;
+	}
+
+	if (FD_ISSET(fd, &rset) || FD_ISSET(fd, &wset)) {
+		int status;
+
+		len = sizeof(ret);
+		status = getsockopt(fd, SOL_SOCKET, SO_ERROR, &ret, &len);
+		if (status < 0) {
+			ret = -errno;
+			goto done;
+		}
+
+		/* Oops - something wrong with connect */
+		if (ret)
+			ret = -ret;
+	}
+
+done:
+	fcntl(fd, F_SETFL, flags);
+	return ret;
+}
+
+static unsigned short getport(struct sockaddr_in *addr,
+			 unsigned long prog, unsigned long vers, int prot)
+{
+	CLIENT *client;
+	enum clnt_stat status;
+	struct pmap parms;
+	int ret, sock;
+	struct sockaddr_in laddr, saddr;
+	struct timeval tout = {0, 0};
+	socklen_t len;
+	unsigned int send_sz = 0;
+	unsigned int recv_sz = 0;
+	unsigned short port;
+
+	memset(&laddr, 0, sizeof(laddr));
+	memset(&saddr, 0, sizeof(saddr));
+	memset(&parms, 0, sizeof(parms));
+
+	memcpy(&saddr, addr, sizeof(saddr));
+	saddr.sin_port = htons(PMAPPORT);
+
+	if (prot == IPPROTO_TCP) {
+		sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
+		if (sock == -1) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			return 0;
+		}
+
+		tout.tv_sec = TOUT_TCP;
+
+		ret = connect_nb(sock, &saddr, &tout);
+		if (ret == -1) {
+			close(sock);
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			return 0;
+		}
+	} else {
+		/*
+		 * bind to any unused port.  If we left this up to the rpc
+		 * layer, it would bind to a reserved port, which has been shown
+		 * to exhaust the reserved port range in some situations.
+		 */
+		sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
+		if (sock == -1) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			return 0;
+		}
+
+		laddr.sin_family = AF_INET;
+		laddr.sin_port = 0;
+		laddr.sin_addr.s_addr = htonl(INADDR_ANY);
+
+		tout.tv_sec = TOUT_UDP;
+
+		send_sz = RPCSMALLMSGSIZE;
+		recv_sz = RPCSMALLMSGSIZE;
+
+		len = sizeof(struct sockaddr_in);
+		if (bind(sock, (struct sockaddr *)&laddr, len) < 0) {
+			close(sock);
+			sock = RPC_ANYSOCK;
+			/* FALLTHROUGH */
+		}
+	}
+
+	client = clntudp_bufcreate(&saddr, PMAPPROG, PMAPVERS,
+				   tout, &sock, send_sz, recv_sz);
+	if (!client) {
+		close(sock);
+		rpc_createerr.cf_stat = RPC_RPCBFAILURE;
+		return 0;
+	}
+
+	clnt_control(client, CLSET_FD_CLOSE, NULL);
+
+	status = clnt_call(client, PMAPPROC_NULL,
+			(xdrproc_t) xdr_void, 0, (xdrproc_t) xdr_void, 0, tout);
+
+	if (status == RPC_SUCCESS) {
+		parms.pm_prog = prog;
+		parms.pm_vers = vers;
+		parms.pm_prot = prot;
+
+		status = clnt_call(client, PMAPPROC_GETPORT,
+				(xdrproc_t) xdr_pmap, (caddr_t) &parms,
+				(xdrproc_t) xdr_u_short, (caddr_t) &port,
+				tout);
+	}
+
+
+	if (status != RPC_SUCCESS) {
+		clnt_geterr(client, &rpc_createerr.cf_error);
+		rpc_createerr.cf_stat = status;
+		clnt_destroy(client);
+		return 0;
+	}
+
+	clnt_destroy(client);
+
+	return htons(port);
+}
+
 int main(argc, argv)
 int argc;
 char **argv;
@@ -82,7 +262,7 @@
 	enum clnt_stat clnt_stat;
 	struct hostent *hp;
 	struct sockaddr_in server_addr;
-	int msock;
+	int ret, msock;
 	struct timeval total_timeout;
 	struct timeval pertry_timeout;
 	int c;
@@ -171,13 +351,32 @@
 
 	/* create mount deamon client */
 
-	server_addr.sin_port = 0;
-	msock = RPC_ANYSOCK;
-	if ((mclient = clnttcp_create(&server_addr,
-	    MOUNTPROG, MOUNTVERS, &msock, 0, 0)) == NULL) {
-		server_addr.sin_port = 0;
+	mclient = NULL;
+	msock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
+	if (msock != -1) {
+		server_addr.sin_port = getport(&server_addr,
+					 MOUNTPROG, MOUNTVERS, IPPROTO_TCP);
+		if (server_addr.sin_port) {
+			ret = connect_nb(msock, &server_addr, 0);
+			if (ret != -1)
+				mclient = clnttcp_create(&server_addr,
+						MOUNTPROG, MOUNTVERS, &msock,
+						0, 0);
+			else
+				close(msock);
+		} else
+			close(msock);
+	}
+
+	if (!mclient) {
+		server_addr.sin_port = getport(&server_addr,
+					 MOUNTPROG, MOUNTVERS, IPPROTO_UDP);
+		if (!server_addr.sin_port) {
+			clnt_pcreateerror("portmap getport");
+			exit(1);
+		}
 		msock = RPC_ANYSOCK;
-		pertry_timeout.tv_sec = 3;
+		pertry_timeout.tv_sec = TOUT_UDP;
 		pertry_timeout.tv_usec = 0;
 		if ((mclient = clntudp_create(&server_addr,
 		    MOUNTPROG, MOUNTVERS, pertry_timeout, &msock)) == NULL) {
@@ -186,11 +385,19 @@
 		}
 	}
 	mclient->cl_auth = authunix_create_default();
-	total_timeout.tv_sec = 20;
+	total_timeout.tv_sec = TOT_TOUT;
 	total_timeout.tv_usec = 0;
 
 	if (eflag) {
 		memset(&exportlist, '\0', sizeof(exportlist));
+
+		clnt_stat = clnt_call(mclient, MOUNTPROC_NULL,
+			(xdrproc_t) xdr_void, NULL, (xdrproc_t) xdr_void,
+			NULL, total_timeout);
+		if (clnt_stat != RPC_SUCCESS) {
+			clnt_perror(mclient, "rpc mount null");
+			exit(1);
+		}
 		clnt_stat = clnt_call(mclient, MOUNTPROC_EXPORT,
 			(xdrproc_t) xdr_void, NULL,
 			(xdrproc_t) xdr_exports, (caddr_t) &exportlist,



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

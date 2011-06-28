Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmfepo102.cox.net ([68.230.241.214]:58151 "EHLO
	eastrmfepo102.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1F1W1z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 18:27:55 -0400
From: Tom Haynes <tdh@excfb.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: [PATCH 1/1] Remove warnings on various platforms
Date: Tue, 28 Jun 2011 17:22:03 -0500
Message-Id: <1309299723-31539-2-git-send-email-tdh@excfb.com>
In-Reply-To: <y>
References: <y>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Signed-off-by: Tom Haynes <tdh@excfb.com>
---
 basic/subr.c       |    5 ++++-
 basic/test1.c      |    1 +
 basic/test2.c      |    1 +
 basic/test3.c      |    1 +
 basic/test4.c      |    1 +
 basic/test4a.c     |    1 +
 basic/test5.c      |    1 +
 basic/test5a.c     |    1 +
 basic/test5b.c     |    1 +
 basic/test6.c      |    1 +
 basic/test7.c      |    1 +
 basic/test7a.c     |    1 +
 basic/test7b.c     |    1 +
 basic/test8.c      |    1 +
 basic/test9.c      |    1 +
 domount.c          |    3 +++
 general/large.c    |    1 +
 general/stat.c     |    1 +
 getopt.c           |    3 +++
 special/dupreq.c   |    1 +
 special/negseek.c  |    1 +
 special/nfsidem.c  |    1 +
 special/nstat.c    |    1 +
 special/rename.c   |    1 +
 special/rewind.c   |    6 +++++-
 special/stat.c     |    1 +
 special/touchn.c   |    6 ++++--
 special/truncate.c |    6 +++++-
 tools/dirdmp.c     |    1 +
 tools/dirprt.c     |    1 +
 tools/pmapbrd.c    |   15 ++++++++-------
 tools/tcpd.c       |    2 +-
 tools/udp.c        |    2 +-
 tools/udpd.c       |    2 +-
 34 files changed, 59 insertions(+), 15 deletions(-)

diff --git a/basic/subr.c b/basic/subr.c
index cf220b7..dafff4f 100644
--- a/basic/subr.c
+++ b/basic/subr.c
@@ -19,17 +19,20 @@
 #endif
 
 #include <sys/types.h>
-#include <sys/timeb.h>
 
 #ifdef DOSorWIN32
+#include <sys/timeb.h>
 #include <time.h>
 #else
 #include <sys/time.h>
 #endif
+
 #include <sys/stat.h>
+#include <fcntl.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+
 #ifdef STDARG
 #include <stdarg.h>
 #endif
diff --git a/basic/test1.c b/basic/test1.c
index 6b15c34..18514ea 100644
--- a/basic/test1.c
+++ b/basic/test1.c
@@ -50,6 +50,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test2.c b/basic/test2.c
index cdb52eb..f6f9e2f 100644
--- a/basic/test2.c
+++ b/basic/test2.c
@@ -48,6 +48,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test3.c b/basic/test3.c
index c53fff8..7b31da8 100644
--- a/basic/test3.c
+++ b/basic/test3.c
@@ -48,6 +48,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test4.c b/basic/test4.c
index f72e956..416c0a6 100644
--- a/basic/test4.c
+++ b/basic/test4.c
@@ -52,6 +52,7 @@ usage()
 		"          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test4a.c b/basic/test4a.c
index 336ed74..1706b1a 100644
--- a/basic/test4a.c
+++ b/basic/test4a.c
@@ -52,6 +52,7 @@ usage()
 		"          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test5.c b/basic/test5.c
index f9463ae..6ba9e87 100644
--- a/basic/test5.c
+++ b/basic/test5.c
@@ -80,6 +80,7 @@ usage()
 #endif
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test5a.c b/basic/test5a.c
index 716d917..bb4cbd5 100644
--- a/basic/test5a.c
+++ b/basic/test5a.c
@@ -79,6 +79,7 @@ usage()
 #endif
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test5b.c b/basic/test5b.c
index 7062680..4d8d2c7 100644
--- a/basic/test5b.c
+++ b/basic/test5b.c
@@ -60,6 +60,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test6.c b/basic/test6.c
index 1d64c88..96388f2 100644
--- a/basic/test6.c
+++ b/basic/test6.c
@@ -65,6 +65,7 @@ usage()
 	fprintf(stdout, "          i    Ignore non-test files dir entries\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test7.c b/basic/test7.c
index f7b3e2e..d19685f 100644
--- a/basic/test7.c
+++ b/basic/test7.c
@@ -53,6 +53,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test7a.c b/basic/test7a.c
index 1e4170c..bc8f363 100644
--- a/basic/test7a.c
+++ b/basic/test7a.c
@@ -51,6 +51,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test7b.c b/basic/test7b.c
index 2f5b119..925b1fc 100644
--- a/basic/test7b.c
+++ b/basic/test7b.c
@@ -53,6 +53,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test8.c b/basic/test8.c
index ea9aa0c..d65eb3a 100644
--- a/basic/test8.c
+++ b/basic/test8.c
@@ -55,6 +55,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/basic/test9.c b/basic/test9.c
index ef68fc2..f376109 100644
--- a/basic/test9.c
+++ b/basic/test9.c
@@ -65,6 +65,7 @@ usage()
 	fprintf(stdout, "          n    Suppress test directory create operations\n");
 }
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/domount.c b/domount.c
index 8982684..5b2fb80 100644
--- a/domount.c
+++ b/domount.c
@@ -8,7 +8,10 @@
  */
 
 #include <stdio.h>
+#include <stdlib.h>
+#include <strings.h>
 
+int
 main(argc, argv)
 	int argc;
 	char **argv;
diff --git a/general/large.c b/general/large.c
index 5dd2950..b5bad18 100644
--- a/general/large.c
+++ b/general/large.c
@@ -49,6 +49,7 @@ int	nc, nl, np, nxo, na;
 
 #define	cunlink(s)	if (s) unlink(s)
 
+int
 main(argc, argv)
 	char **argv;
 {
diff --git a/general/stat.c b/general/stat.c
index b9128ae..67c58f5 100644
--- a/general/stat.c
+++ b/general/stat.c
@@ -24,6 +24,7 @@ char	*Prog, *File;
 int	getattfmt();
 void	prtstat();
 
+int
 main(argc, argv)
 	int	argc;
 	char	*argv[];
diff --git a/getopt.c b/getopt.c
index da64713..ae1eb11 100644
--- a/getopt.c
+++ b/getopt.c
@@ -36,6 +36,7 @@
 	(void) write(2, errbuf, 2);}
 
 #include <string.h>
+#include <stdlib.h>
 
 int	opterr = 1;
 int	optind = 1;
@@ -94,7 +95,9 @@ char	**argv, *opts;
 
 #include	<stdio.h>
 
+int
 main(ac, av)
+int	ac;
 char	**av;
 {
 	register int	i;
diff --git a/special/dupreq.c b/special/dupreq.c
index 29174a6..8a896ee 100644
--- a/special/dupreq.c
+++ b/special/dupreq.c
@@ -17,6 +17,7 @@
 #include <fcntl.h>
 #endif
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/special/negseek.c b/special/negseek.c
index c974070..00d42d4 100644
--- a/special/negseek.c
+++ b/special/negseek.c
@@ -21,6 +21,7 @@
 #endif
 #endif /* DOSorWIN32 */
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/special/nfsidem.c b/special/nfsidem.c
index ac95c39..5bae363 100644
--- a/special/nfsidem.c
+++ b/special/nfsidem.c
@@ -53,6 +53,7 @@ static char TBAR[MAXPATHLEN];
 static char LBAR[MAXPATHLEN];
 static char str[STRCHARS];
 
+int
 main(ac,av)
 	int ac;
 	char *av[];
diff --git a/special/nstat.c b/special/nstat.c
index 87c1def..fdbd3f9 100644
--- a/special/nstat.c
+++ b/special/nstat.c
@@ -26,6 +26,7 @@
 
 static int stats = 0;
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/special/rename.c b/special/rename.c
index 8abbc60..a16d7be 100644
--- a/special/rename.c
+++ b/special/rename.c
@@ -21,6 +21,7 @@
 #endif
 #endif /* DOSorWIN32 */
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/special/rewind.c b/special/rewind.c
index b5400d3..32003ea 100644
--- a/special/rewind.c
+++ b/special/rewind.c
@@ -14,7 +14,11 @@
 #include <unistd.h>
 #endif /* DOSorWIN32 */
 
-main()
+/*ARGSUSED*/    
+int
+main(argc, argv)
+	int argc;
+	char *argv[];
 {
 	char buffer[8192];
 	int size = 8192;
diff --git a/special/stat.c b/special/stat.c
index 941eec1..c87f422 100644
--- a/special/stat.c
+++ b/special/stat.c
@@ -34,6 +34,7 @@ static int stats = 0;
 
 static void statit ARGS_((char *));
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/special/touchn.c b/special/touchn.c
index 3038eba..fdbfe14 100644
--- a/special/touchn.c
+++ b/special/touchn.c
@@ -18,8 +18,10 @@
 
 #include "../tests.h"
 
-main(argc,argv)
-char **argv;
+int
+main(argc, argv)
+	int argc;
+	char **argv;
 {
 	int n;
 	char buf[1024];
diff --git a/special/truncate.c b/special/truncate.c
index 4c4f076..50b65ad 100644
--- a/special/truncate.c
+++ b/special/truncate.c
@@ -18,7 +18,11 @@
 #include <unistd.h>
 #endif /* DOSorWIN32 */
 
-main()
+/*ARGSUSED*/    
+int
+main(argc, argv)
+	int argc;
+	char *argv[];
 {
 	int fd;
 	struct stat statb;
diff --git a/tools/dirdmp.c b/tools/dirdmp.c
index 76ac2c3..9b87e11 100644
--- a/tools/dirdmp.c
+++ b/tools/dirdmp.c
@@ -31,6 +31,7 @@ static DIR * my_opendir ARGS_((char *name));
 static void print ARGS_((char *));
 static struct dirent *my_readdir ARGS_((DIR *dirp));
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/tools/dirprt.c b/tools/dirprt.c
index a8b50ea..9d5fb98 100644
--- a/tools/dirprt.c
+++ b/tools/dirprt.c
@@ -34,6 +34,7 @@
 static DIR *my_opendir ARGS_((char *));
 static void print ARGS_((char *));
 
+int
 main(argc, argv)
 	int argc;
 	char *argv[];
diff --git a/tools/pmapbrd.c b/tools/pmapbrd.c
index 2bb05b6..71aadd8 100644
--- a/tools/pmapbrd.c
+++ b/tools/pmapbrd.c
@@ -174,8 +174,9 @@ main(argc, argv)
 		 * XXX shouldn't have to cast eachresult?
 		 */
 		clnt_stat =
-		    clnt_broadcast_time(sock, RPROG, RVERS, RPROC_NUM, xdr_void, &a,
-		    xdr_void, &b, (resultproc_t)eachresult, &t);
+		    clnt_broadcast_time(sock, RPROG, RVERS, RPROC_NUM,
+		    (xdrproc_t)xdr_void, &a, (xdrproc_t)xdr_void, &b,
+		    (resultproc_t)eachresult, &t);
 		if(clnt_stat != RPC_TIMEDOUT) {
 			printf("error: clnt_stat = %d\n", clnt_stat);
 			clnt_perrno(clnt_stat);
@@ -243,9 +244,9 @@ xdr_rmtcallres(xdrs, crp)
 {
 
 #ifdef SVR3
-	if (xdr_reference(xdrs, (caddr_t *)&crp->port_ptr, sizeof (ulong), xdr_u_long) &&
+	if (xdr_reference(xdrs, (caddr_t *)&crp->port_ptr, sizeof (ulong), (xdrproc_t)xdr_u_long) &&
 #else
-	if (xdr_reference(xdrs, (caddr_t *)&crp->port_ptr, sizeof (u_long), xdr_u_long) &&
+	if (xdr_reference(xdrs, (caddr_t *)&crp->port_ptr, sizeof (u_long), (xdrproc_t)xdr_u_long) &&
 #endif
 		xdr_u_long(xdrs, &crp->resultslen))
 		return ((*(crp->xdr_results))(xdrs, crp->results_ptr));
@@ -387,7 +388,7 @@ clnt_broadcast_time(sock, prog, vers, proc, xargs, argsp, xresults,
 recv_again:
 	msg.acpted_rply.ar_verf = _null_auth;
 	msg.acpted_rply.ar_results.where = (caddr_t)&r;
-	msg.acpted_rply.ar_results.proc = xdr_rmtcallres;
+	msg.acpted_rply.ar_results.proc = (xdrproc_t)xdr_rmtcallres;
 	readfds = mask;
 	switch (select(32, (fd_set *)&readfds, (fd_set *)NULL, (fd_set *)NULL,
 			t)) {
@@ -409,7 +410,7 @@ recv_again:
 try_again:
 	fromlen = sizeof(struct sockaddr);
 	inlen = recvfrom(sock, inbuf, MAX_BROADCAST_SIZE, 0,
-		(struct sockaddr *)&raddr, &fromlen);
+		(struct sockaddr *)&raddr, (socklen_t *)&fromlen);
 	if (inlen < 0) {
 		if (errno == EINTR)
 			goto try_again;
@@ -447,7 +448,7 @@ try_again:
 		/* otherwise, just random garbage */
 	}
 	xdrs->x_op = XDR_FREE;
-	msg.acpted_rply.ar_results.proc = xdr_void;
+	msg.acpted_rply.ar_results.proc = (xdrproc_t)xdr_void;
 	(void)xdr_replymsg(xdrs, &msg);
 	(void)(*xresults)(xdrs, resultsp);
 	xdr_destroy(xdrs);
diff --git a/tools/tcpd.c b/tools/tcpd.c
index 8ab8877..b81945b 100644
--- a/tools/tcpd.c
+++ b/tools/tcpd.c
@@ -55,7 +55,7 @@ main(argc, argv)
 	while(1) {
 		fprintf(stderr, "%s awaiting accept\n", argv[0]);
 		addrlen = sizeof(struct sockaddr_in);
-		if ((ns = accept(s, (struct sockaddr *)&addr, &addrlen)) < 0)
+		if ((ns = accept(s, (struct sockaddr *)&addr, (socklen_t *)&addrlen)) < 0)
 			xxit("accept");
 #ifdef __STDC__
 		if (hp = gethostbyaddr((const char *)&addr.sin_addr,
diff --git a/tools/udp.c b/tools/udp.c
index 70dc495..cc83646 100644
--- a/tools/udp.c
+++ b/tools/udp.c
@@ -62,7 +62,7 @@ main(argc, argv)
 
 	ret = sendto(s, buf, len, 0, (struct sockaddr *)&addr, addrlen);
 	fprintf(stderr, " sendto ret %d (len %d)\n", ret, len);
-	ret = recvfrom(s, buf, BUFSIZ, 0, (struct sockaddr *)&addr, &addrlen);
+	ret = recvfrom(s, buf, BUFSIZ, 0, (struct sockaddr *)&addr, (socklen_t *)&addrlen);
 	fprintf(stderr, " recvfrom ret %d\n", ret);
 
 	if (ret != len || *buf != *msg + 1 || strcmp(buf+1, msg+1))
diff --git a/tools/udpd.c b/tools/udpd.c
index 17fdec5..7f6c592 100644
--- a/tools/udpd.c
+++ b/tools/udpd.c
@@ -52,7 +52,7 @@ main(argc, argv)
 		fprintf(stderr, "%s awaiting request\n", argv[0]);
 		addrlen = sizeof(struct sockaddr_in);
 		ret = recvfrom(s, buf, BUFSIZ, 0, (struct sockaddr *)&addr,
-			       &addrlen);
+			       (socklen_t *)&addrlen);
 		if (ret < 0)
 			xxit("recvfrom");
 #ifdef __STDC__
-- 
1.7.5.4


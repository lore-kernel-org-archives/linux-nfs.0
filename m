From: "H. J. Lu" <hjl@lucon.org>
Subject: PATCH: Respect /etc/services
Date: Thu, 12 Sep 2002 10:03:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020912100350.A11903@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc01.attbi.com ([204.127.202.61])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pXNm-0005ZO-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Sep 2002 10:03:58 -0700
Received: from ocean.lucon.org ([12.234.143.38]) by sccrmhc01.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with ESMTP
          id <20020912170351.GAWF16673.sccrmhc01.attbi.com@ocean.lucon.org>
          for <nfs@lists.sourceforge.net>; Thu, 12 Sep 2002 17:03:51 +0000
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

FYI, I am going to check in this patch shortly.


H.J.
----
Index: configure.in
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/configure.in,v
retrieving revision 1.30
diff -u -p -r1.30 configure.in
--- configure.in	7 Apr 2002 21:00:56 -0000	1.30
+++ configure.in	12 Sep 2002 16:58:35 -0000
@@ -98,6 +98,8 @@ dnl ************************************
 dnl Check for functions
 dnl *************************************************************
 AC_HAVE_FUNCS(innetgr)
+AC_HAVE_FUNCS(svctcp_socket)
+AC_HAVE_FUNCS(svcudp_socket)
 
 dnl *************************************************************
 dnl Export some path names to config.h
Index: support/include/config.h.in
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/include/config.h.in,v
retrieving revision 1.1.1.1
diff -u -p -r1.1.1.1 config.h.in
--- support/include/config.h.in	18 Oct 1999 23:21:12 -0000	1.1.1.1
+++ support/include/config.h.in	12 Sep 2002 16:58:35 -0000
@@ -9,6 +9,14 @@
  */
 #undef  HAVE_INNETGR
 
+/* Define this if you have svctcp_socket
+ */
+#undef  HAVE_SVCTCP_SOCKET
+
+/* Define this if you have svcudp_socket
+ */
+#undef  HAVE_SVCUDP_SOCKET
+
 /* Define this if you want NFSv3 support compiled in
  */
 #undef  NFS3_SUPPORTED
Index: support/include/nfslib.h
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/include/nfslib.h,v
retrieving revision 1.6
diff -u -p -r1.6 nfslib.h
--- support/include/nfslib.h	29 May 2002 06:07:43 -0000	1.6
+++ support/include/nfslib.h	12 Sep 2002 16:58:35 -0000
@@ -125,4 +125,7 @@ struct nfs_fh_len *	getfh_size(struct so
 /* lockd. */
 int			lockdsvc();
 
+extern			int svctcp_socket (u_long __number, int __reuse);
+extern			int svcudp_socket (u_long __number, int __reuse);
+
 #endif /* NFSLIB_H */
Index: support/nfs/Makefile
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/nfs/Makefile,v
retrieving revision 1.1.1.1
diff -u -p -r1.1.1.1 Makefile
--- support/nfs/Makefile	18 Oct 1999 23:21:12 -0000	1.1.1.1
+++ support/nfs/Makefile	12 Sep 2002 16:58:35 -0000
@@ -5,7 +5,8 @@
 LIBNAME	= libnfs.a
 OBJS	= exports.o rmtab.o xio.o \
 	  rpcmisc.o rpcdispatch.o xlog.o xmalloc.o wildmat.o \
-	  nfssvc.o nfsclient.o nfsexport.o getfh.o nfsctl.o lockdsvc.o
+	  nfssvc.o nfsclient.o nfsexport.o getfh.o nfsctl.o \
+	  lockdsvc.o svc_socket.o
 
 include $(TOP)rules.mk
 
Index: support/nfs/rpcmisc.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/nfs/rpcmisc.c,v
retrieving revision 1.11
diff -u -p -r1.11 rpcmisc.c
--- support/nfs/rpcmisc.c	2 Apr 2001 01:46:16 -0000	1.11
+++ support/nfs/rpcmisc.c	12 Sep 2002 16:58:35 -0000
@@ -73,11 +73,15 @@ rpc_init(char *name, int prog, int vers,
 				transp = last_transp;
 				goto udp_transport;
 			}
-			if ((sock = makesock(defport, IPPROTO_UDP)) < 0) {
+			if (defport == 0)
+				sock = RPC_ANYSOCK;
+			else if ((sock = makesock(defport, IPPROTO_UDP)) < 0) {
 				xlog(L_FATAL, "%s: cannot make a UDP socket\n",
 						name);
 			}
 		}
+		if (sock == RPC_ANYSOCK)
+			sock = svcudp_socket (prog, 1);
 		transp = svcudp_create(sock);
 		if (transp == NULL) {
 			xlog(L_FATAL, "cannot create udp service.");
@@ -99,11 +103,15 @@ rpc_init(char *name, int prog, int vers,
 				transp = last_transp;
 				goto tcp_transport;
 			}
-			if ((sock = makesock(defport, IPPROTO_TCP)) < 0) {
+			if (defport == 0)
+				sock = RPC_ANYSOCK;
+			else if ((sock = makesock(defport, IPPROTO_TCP)) < 0) {
 				xlog(L_FATAL, "%s: cannot make a TCP socket\n",
 						name);
 			}
 		}
+		if (sock == RPC_ANYSOCK)
+			sock = svctcp_socket (prog, 1);
 		transp = svctcp_create(sock, 0, 0);
 		if (transp == NULL) {
 			xlog(L_FATAL, "cannot create tcp service.");
Index: utils/nfsd/nfsd.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/nfsd/nfsd.c,v
retrieving revision 1.3
diff -u -p -r1.3 nfsd.c
--- utils/nfsd/nfsd.c	26 Nov 2001 19:57:57 -0000	1.3
+++ utils/nfsd/nfsd.c	12 Sep 2002 16:58:35 -0000
@@ -17,6 +17,7 @@
 #include <errno.h>
 #include <getopt.h>
 #include <syslog.h>
+#include <netdb.h>
 #include "nfslib.h"
 
 static void	usage(const char *);
@@ -25,10 +26,13 @@ int
 main(int argc, char **argv)
 {
 	int	count = 1, c, error, port, fd;
+	struct servent *ent;
 
-	port = 2049;
-
-	/* FIXME: Check for nfs in /etc/services */
+	ent = getservbyname ("nfs", "udp");
+	if (ent != NULL)
+		port = ntohs (ent->s_port);
+	else
+		port = 2049;
 
 	while ((c = getopt(argc, argv, "hp:P:")) != EOF) {
 		switch(c) {
Index: utils/rquotad/rquota_svc.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/rquotad/rquota_svc.c,v
retrieving revision 1.7
diff -u -p -r1.7 rquota_svc.c
--- utils/rquotad/rquota_svc.c	28 May 2001 18:37:47 -0000	1.7
+++ utils/rquotad/rquota_svc.c	12 Sep 2002 16:58:35 -0000
@@ -38,6 +38,7 @@
 #include <signal.h>
 #include <getopt.h>
 #include <rpcmisc.h>
+#include <nfslib.h>
 
 #ifdef __STDC__
 #define SIG_PF void(*)(int)
@@ -222,11 +223,20 @@ usage(const char *prog, int n)
   exit(n);
 }
 
+static void
+killer (int sig)
+{
+   (void) pmap_unset(RQUOTAPROG, RQUOTAVERS);
+   (void) pmap_unset(RQUOTAPROG, EXT_RQUOTAVERS);
+   syslog(LOG_ERR, "caught signal %d, un-registering and exiting.", sig);
+}
+
 int main(int argc, char **argv)
 {
    register SVCXPRT *transp;
    char c;
    int port = 0;
+   struct sigaction sa;
 
    (void) pmap_unset(RQUOTAPROG, RQUOTAVERS);
    (void) pmap_unset(RQUOTAPROG, EXT_RQUOTAVERS);
@@ -263,12 +273,20 @@ int main(int argc, char **argv)
    }
 
    /* WARNING: the following works on Linux and SysV, but not BSD! */
-   signal(SIGCHLD, SIG_IGN);
+   sa.sa_handler = SIG_IGN;
+   sa.sa_flags = 0;
+   sigemptyset(&sa.sa_mask);
+   sigaction(SIGCHLD, &sa, NULL);
+
+   sa.sa_handler = killer;
+   sigaction(SIGHUP, &sa, NULL);
+   sigaction(SIGINT, &sa, NULL);
+   sigaction(SIGTERM, &sa, NULL);
 
    if (port)
      transp = svcudp_create(makesock(port, IPPROTO_UDP));
    else
-     transp = svcudp_create(RPC_ANYSOCK);
+     transp = svcudp_create(svcudp_socket (RQUOTAPROG, 1));
    if (transp == NULL) {
       syslog(LOG_ERR, "cannot create udp service.");
       exit(1);
--- /dev/null	Thu Apr 11 07:25:15 2002
+++ support/nfs/svc_socket.c	Thu Sep 12 08:46:41 2002
@@ -0,0 +1,187 @@
+/* Copyright (C) 2002 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, write to the Free
+   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
+   02111-1307 USA.  */
+
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <netdb.h>
+#include <rpc/rpc.h>
+#include <sys/socket.h>
+#include <errno.h>
+
+#ifdef _LIBC
+# include <libintl.h>
+#else
+# include "config.h"
+# ifndef _
+#  define _(s)			(s)
+# endif
+# define __socket(d, t, p)	socket ((d), (t), (p))
+# define __close(f)		close ((f))
+#endif
+
+#if !defined HAVE_SVCTCP_SOCKET || !defined HAVE_SVCUDP_SOCKET
+static int
+svc_socket (u_long number, int type, int protocol, int reuse)
+{
+  struct sockaddr_in addr;
+  socklen_t len = sizeof (struct sockaddr_in);
+  char rpcdata [1024], servdata [1024];
+  struct rpcent rpcbuf, *rpcp;
+  struct servent servbuf, *servp;
+  int sock, ret;
+  const char *proto = protocol == IPPROTO_TCP ? "tcp" : "udp";
+
+  if ((sock = __socket (AF_INET, type, protocol)) < 0)
+    {
+      perror (_("svc_socket: socket creation problem"));
+      return sock;
+    }
+
+  if (reuse)
+    {
+      ret = 1;
+      ret = setsockopt (sock, SOL_SOCKET, SO_REUSEADDR, &ret,
+			sizeof (ret));
+      if (ret < 0)
+	{
+	  perror (_("svc_socket: socket reuse problem"));
+	  return ret;
+	}
+    }
+
+  __bzero ((char *) &addr, sizeof (addr));
+  addr.sin_family = AF_INET;
+
+  ret = getrpcbynumber_r (number, &rpcbuf, rpcdata, sizeof rpcdata,
+			  &rpcp);
+  if (ret == 0 && rpcp != NULL)
+    {
+      /* First try name.  */
+      ret = getservbyname_r (rpcp->r_name, proto, &servbuf, servdata,
+			     sizeof servdata, &servp);
+      if ((ret != 0 || servp == NULL) && rpcp->r_aliases)
+	{
+	  const char **a;
+
+	  /* Then we try aliases.  */
+	  for (a = (const char **) rpcp->r_aliases; *a != NULL; a++) 
+	    {
+	      ret = getservbyname_r (*a, proto, &servbuf, servdata,
+				     sizeof servdata, &servp);
+	      if (ret == 0 && servp != NULL)
+		break;
+	    }
+	}
+    }
+
+  if (ret == 0 && servp != NULL)
+    {
+      addr.sin_port = servp->s_port;
+      if (bind (sock, (struct sockaddr *) &addr, len) < 0)
+	{
+	  perror (_("svc_socket: bind problem"));
+	  (void) __close (sock);
+	  sock = -1;
+	}
+    }
+  else
+    {
+      if (bindresvport (sock, &addr))
+	{
+	  addr.sin_port = 0;
+	  if (bind (sock, (struct sockaddr *) &addr, len) < 0)
+	    {
+	      perror (_("svc_socket: bind problem"));
+	      (void) __close (sock);
+	      sock = -1;
+	    }
+	}
+    }
+
+  return sock;
+}
+#endif
+
+#ifndef HAVE_SVCTCP_SOCKET
+/*
+ * Create and bind a TCP socket based on program number
+ */
+int
+svctcp_socket (u_long number, int reuse)
+{
+  return svc_socket (number, SOCK_STREAM, IPPROTO_TCP, reuse);
+}
+#endif
+
+#ifndef HAVE_SVCUDP_SOCKET
+/*
+ * Create and bind a UDP socket based on program number
+ */
+int
+svcudp_socket (u_long number, int reuse)
+{
+  return svc_socket (number, SOCK_DGRAM, IPPROTO_UDP, reuse);
+}
+#endif
+
+#ifdef TEST
+static int
+check (u_long number, u_short port, int protocol, int reuse)
+{
+  int socket;
+  int result;
+  struct sockaddr_in addr;
+  socklen_t len = sizeof (struct sockaddr_in);
+
+  if (protocol == IPPROTO_TCP)
+    socket = svctcp_socket (number, reuse);
+  else
+    socket = svcudp_socket (number, reuse);
+
+  if (socket < 0)
+    return 1;
+
+  result = getsockname (socket, (struct sockaddr *) &addr, &len);
+  if (result == 0)
+    {
+      if (port != 0 && ntohs (addr.sin_port) != port)
+	printf ("Program: %ld, expect port: %d, got: %d\n",
+		number, port, ntohs (addr.sin_port)); 
+      else
+	printf ("Program: %ld, port: %d\n",
+		number, ntohs (addr.sin_port)); 
+    }
+
+  close (socket);
+  return result;
+}
+
+int
+main (void)
+{
+  int result = 0;
+
+  result += check (100001, 0, IPPROTO_TCP, 0);
+  result += check (100001, 0, IPPROTO_UDP, 0);
+  result += check (100003, 2049, IPPROTO_TCP, 1);
+  result += check (100003, 2049, IPPROTO_UDP, 1);
+
+  return result;
+}
+#endif


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

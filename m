From: Usha Ketineni <ketineni@us.ibm.com>
Subject: [NFS][PATCH] Fix to start nfs services through rsh
Date: Mon, 24 Oct 2005 11:49:37 -0700
Message-ID: <1130179778.4887.33.camel@ibm-rf40cz9kb83.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EU7PJ-00040h-OY
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 11:50:53 -0700
Received: from over.co.us.ibm.com ([32.97.110.157] helo=bldfb.esmtp.ibm.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EU7PJ-0007uO-J2
	for nfs@lists.sourceforge.net; Mon, 24 Oct 2005 11:50:53 -0700
Received: from e36.co.us.ibm.com (e36.boulder.ibm.com [9.17.249.46])
	by bldfb.esmtp.ibm.com (8.12.11/8.12.11) with ESMTP id j9OIo011019711
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 14:50:00 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9OIneAb006750
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 14:49:40 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9OInedH447476
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 12:49:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9OIndXM026448
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 12:49:40 -0600
Received: from sapho.beaverton.ibm.com (sapho.beaverton.ibm.com [9.47.22.85])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j9OIndYv026390
	for <nfs@lists.sourceforge.net>; Mon, 24 Oct 2005 12:49:39 -0600
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


When issuing "rsh hostname /sbin/service nfs start"
rsh gives the error message "Starting NFS mountd: svc_tcp.c - cannot
getsockname or listen: Invalid argument [FAILED]"

When mountd is invoked by rshd, file descriptor 0 is a socket, hence
getsockname in rpc_init() succeeds so, rpc_init() tries to listen on
that socket in svc_tcp_create(). The socket is a connected socket, but
this code is assuming the socket came from inetd (or xinetd) and listen
& accept can be called to establish a connection.

When mountd is invoked from the command line or sshd, file descriptor 0
is not a socket.

Here is a fix for starting the nfs services through rsh which checks
whether 0 is not a connected socket and if it is, sets socket to
RPC_ANYSOCK so, svc_tcp_create() will create a new socket. 

This patched code assumes that any udp socket, or a tcp socket that is
not connected came from inetd and can be passed to svc_udp_create() or
svc_tcp_create().

Signed-off-by: Usha Ketineni <uketinen@us.ibm.com>

--- nfs-utils-1.0.7.orig/support/nfs/rpcmisc.c	2005-10-24 17:19:07.000000000 -0700
+++ nfs-utils-1.0.7/support/nfs/rpcmisc.c	2005-10-24 18:48:23.000000000 -0700
@@ -53,10 +53,17 @@ rpc_init(char *name, int prog, int vers,
 	if (getsockname(0, (struct sockaddr *) &saddr, &asize) == 0
 	    && saddr.sin_family == AF_INET) {
 		int ssize = sizeof (int);
-		_rpcfdtype = 0;
+		int tmp_rpcfdtype = 0;
 		if (getsockopt(0, SOL_SOCKET, SO_TYPE,
 				(char *)&_rpcfdtype, &ssize) == -1)
 			xlog(L_FATAL, "getsockopt failed: %s", strerror(errno));
+		if (_rpcfdtype != SOCK_STREAM || listen(0,5) != -1) {
+			_rpcpmstart = 1;
+			_rpcfdtype = tmp_rpcfdtype;
+		} else {
+			sock = RPC_ANYSOCK;
+			pmap_unset(prog, vers);
+		}
 		_rpcpmstart = 1;
 	} else {
 		pmap_unset(prog, vers);




-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

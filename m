From: olof@austin.ibm.com
Subject: [PATCH] TCP nfsd connection hangs when partial record header is
 received
Date: Mon, 12 May 2003 09:39:27 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.A41.4.44.0305120927550.24170-100000@forte.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net, <neilb@cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Below patch resolves a hang where a TCP nfsd connection will hang even
though new data is received on the socket. We've seen this a few times in
our lab, but it usually happened every few weeks.

If a short record header is received, the SK_BUSY flag is never cleared,
and even though new data arrives, it will not be handled. This in turn
leads to hangs of particular clients (while others will continue to work
without problem).

I also changed the return code for that condition to be the same as for a
(regular) short read.

Patch is against 2.4.20.


Thanks,

Olof


--- net/sunrpc/svcsock.c.orig	2002-11-28 17:53:16.000000000 -0600
+++ net/sunrpc/svcsock.c	2003-05-12 09:33:42.000000000 -0500
@@ -819,8 +819,12 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if ((len = svc_recvfrom(rqstp, &iov, 1, want)) < 0)
 			goto error;
 		svsk->sk_tcplen += len;
-		if (len < want)
-			return 0;
+		if (len < want) {
+			dprintk("svc: short recvfrom while reading record length (%d of %d)\n",
+			        len, want);
+			svc_sock_received(svsk);
+			return -EAGAIN; /* record header not complete */
+		}

 		svsk->sk_reclen = ntohl(svsk->sk_reclen);
 		if (!(svsk->sk_reclen & 0x80000000)) {


---
Olof Johansson                                          Office: 4E002/905
pSeries Linux Development                               IBM Systems Group
Email: olof@austin.ibm.com                            Phone: 512-838-9858



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 4 - TCP nfsd connection hangs when partial record header is received
Date: Wed, 18 Jun 2003 10:30:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQq4-0000Wz-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQlk-0007BV-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 17:25:44 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 10:25:35 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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


From: Olof Johansson <olof@austin.ibm.com>

Below patch resolves a hang where a TCP nfsd connection will hang even
though new data is received on the socket. We've seen this a few times in
our lab, but it usually happened every few weeks.

If a short record header is received, the SK_BUSY flag is never cleared,
and even though new data arrives, it will not be handled. This in turn
leads to hangs of particular clients (while others will continue to work
without problem).

I also changed the return code for that condition to be the same as for a
(regular) short read.


diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-06-18 10:17:26.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-06-18 10:16:06.000000000 +1000
@@ -816,8 +816,12 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

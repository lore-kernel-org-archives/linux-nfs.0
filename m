From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 9 - TCP nfsd connection hangs when partial record header is received
Date: Wed, 21 May 2003 13:12:09 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1R-00061X-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1f-0000vC-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:09 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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

Of these 9 patches against 2.5, some are bug fixes related to NFS over
TCP, and other are resend so stuff that was dropped a week or more ago.

Thanks,
NeilBrown

### Comments for ChangeSet

Below patch resolves a hang where a TCP nfsd connection will hang even
though new data is received on the socket. We've seen this a few times in
our lab, but it usually happened every few weeks.

If a short record header is received, the SK_BUSY flag is never cleared,
and even though new data arrives, it will not be handled. This in turn
leads to hangs of particular clients (while others will continue to work
without problem).

I also changed the return code for that condition to be the same as for a
(regular) short read.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-05-20 16:30:53.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-05-20 16:31:42.000000000 +1000
@@ -886,8 +886,12 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 			goto error;
 		svsk->sk_tcplen += len;
 
-		if (len < want)
-			return 0;
+		if (len < want) {
+			dprintk("svc: short recvfrom while reading record length (%d of %lu)\n",
+			        len, want);
+			svc_sock_received(svsk);
+			return -EAGAIN; /* record header not complete */
+		}
 
 		svsk->sk_reclen = ntohl(svsk->sk_reclen);
 		if (!(svsk->sk_reclen & 0x80000000)) {


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 7 - Fix cmsg setup for sock_sendmsg in svc_sendto
Date: Tue, 23 Sep 2003 09:33:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aB6-0004Dh-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBV-0008Tu-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:37 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBU-0003h0-QK
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:36 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 23 Sep 2003 09:33:23 +1000
To: Linus Torvalds <torvalds@osdl.org>
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

7 patches for knfsd in 2.6.0-testX. All NFSv4 related, except this first one.
Thanks,
NeilBrown

### Comments for ChangeSet

From: Trond Myklebust <trond.myklebust@fys.uio.no>

... see the code in ip_sockglue.c + the macros in socket.h....
AFAICS the control messages have wierd alignment requirements.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-09-23 09:08:09.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-09-23 09:11:18.000000000 +1000
@@ -352,9 +352,9 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
-	struct { struct cmsghdr cmh;
-		struct in_pktinfo pki;
-	} cm;
+	char 		buffer[CMSG_SPACE(sizeof(struct in_pktinfo))];
+	struct cmsghdr *cmh = (struct cmsghdr *)buffer;
+	struct in_pktinfo *pki = (struct in_pktinfo *)CMSG_DATA(cmh);
 	int		len = 0;
 	int		result;
 	int		size;
@@ -374,13 +374,13 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		msg.msg_iovlen  = 0;
 		msg.msg_flags	= MSG_MORE;
 
-		msg.msg_control = &cm;
-		msg.msg_controllen = sizeof(cm);
-		cm.cmh.cmsg_len = sizeof(cm);
-		cm.cmh.cmsg_level = SOL_IP;
-		cm.cmh.cmsg_type = IP_PKTINFO;
-		cm.pki.ipi_ifindex = 0;
-		cm.pki.ipi_spec_dst.s_addr = rqstp->rq_daddr;
+		msg.msg_control = cmh;
+		msg.msg_controllen = sizeof(buffer);
+		cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
+		cmh->cmsg_level = SOL_IP;
+		cmh->cmsg_type = IP_PKTINFO;
+		pki->ipi_ifindex = 0;
+		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr;
 
 		if (sock_sendmsg(sock, &msg, 0) < 0)
 			goto out;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

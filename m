From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: nfsd not working in 2.6.0-test4 on ia64
Date: 08 Sep 2003 00:43:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsllszopo8.fsf@charged.uio.no>
References: <20030903220709.GJ18654@parcelfarce.linux.theplanet.co.uk>
	<16216.2231.419902.317479@gargle.gargle.HOWL>
	<20030905115312.GH18654@parcelfarce.linux.theplanet.co.uk>
	<16219.65533.190871.210282@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wDse-0002LA-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Sep 2003 21:44:00 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wDse-0000Ju-8l
	for nfs@lists.sourceforge.net; Sun, 07 Sep 2003 21:44:00 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16219.65533.190871.210282@gargle.gargle.HOWL>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > On Friday September 5, willy@debian.org wrote:
    >> On Fri, Sep 05, 2003 at 01:53:27PM +1000, Neil Brown wrote:
    >> > Very helpful details.  It looks like a simple case of 32-bit
    >> > parochialism :-)
    >> >
    >> > Does this patch help?
    >>
    >> Nope.  Applied patch, rebooted with it, here's the full details
    >> again (don't think anything changed, but just in case):

     > Ok, I looked more closely at the .h files etc and I think the
     > following is correct (instead of the previous patch).

     > (i.e. sizeof(cm.pki) instead of sizeof(cm)).

Nope see the code in ip_sockglue.c + the macros in socket.h....
AFAICS the control messages have wierd alignment requirements.

Shouldn't it rather be something like the following?

Cheers,
  Trond

--- linux-2.6.0-up/net/sunrpc/svcsock.c.orig	2003-08-30 23:35:33.000000000 -0400
+++ linux-2.6.0-up/net/sunrpc/svcsock.c	2003-09-08 00:39:07.000000000 -0400
@@ -352,9 +352,9 @@
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
-	struct { struct cmsghdr cmh;
-		struct in_pktinfo pki;
-	} cm;
+	char *buffer[CMSG_SPACE(sizeof(struct in_pktinfo))];
+	struct cmsghdr *cmh = (struct cmsghdr *)buffer;
+	struct in_pktinfo *pki = (struct in_pktinfo *)CMSG_DATA(cmh);
 	int		len = 0;
 	int		result;
 	int		size;
@@ -374,13 +374,13 @@
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

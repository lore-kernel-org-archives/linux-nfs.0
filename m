From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd not working in 2.6.0-test4 on ia64
Date: Mon, 8 Sep 2003 14:05:17 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16219.65533.190871.210282@gargle.gargle.HOWL>
References: <20030903220709.GJ18654@parcelfarce.linux.theplanet.co.uk>
	<16216.2231.419902.317479@gargle.gargle.HOWL>
	<20030905115312.GH18654@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wDHI-0006qq-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Sep 2003 21:05:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19wDHH-0000P0-Ho
	for nfs@lists.sourceforge.net; Sun, 07 Sep 2003 21:05:23 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <willy@debian.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Mon, 8 Sep 2003 14:05:18 +1000
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: message from Matthew Wilcox on Friday September 5
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

On Friday September 5, willy@debian.org wrote:
> On Fri, Sep 05, 2003 at 01:53:27PM +1000, Neil Brown wrote:
> > Very helpful details.  
> > It looks like a simple case of 32-bit parochialism :-)
> > 
> > Does this patch help?
> 
> Nope.  Applied patch, rebooted with it, here's the full details again
> (don't think anything changed, but just in case):

Ok, I looked more closely at the .h files etc and I think the
following is correct (instead of the previous patch).

(i.e. sizeof(cm.pki) instead of sizeof(cm)).

NeilBrown


diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-09-08 14:00:16.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-09-08 14:00:11.000000000 +1000
@@ -376,8 +376,8 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		msg.msg_flags	= MSG_MORE;
 
 		msg.msg_control = &cm;
-		msg.msg_controllen = sizeof(cm);
-		cm.cmh.cmsg_len = sizeof(cm);
+		msg.msg_controllen = CMSG_LEN(sizeof(cm.pki));
+		cm.cmh.cmsg_len = CMSG_LEN(sizeof(cm.pki));
 		cm.cmh.cmsg_level = SOL_IP;
 		cm.cmh.cmsg_type = IP_PKTINFO;
 		cm.pki.ipi_ifindex = 0;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd not working in 2.6.0-test4 on ia64
Date: Fri, 5 Sep 2003 13:53:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16216.2231.419902.317479@gargle.gargle.HOWL>
References: <20030903220709.GJ18654@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19v7fM-000468-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 20:53:44 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19v7fK-0002jK-AT
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 20:53:43 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <willy@debian.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 5 Sep 2003 13:53:33 +1000
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: message from Matthew Wilcox on Wednesday September 3
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

On Wednesday September 3, willy@debian.org wrote:
> 
> My mount attempts aren't working.
> 
...
> 
> Then I added full rpc debugging, and got this:
> 
...
> Sep  3 17:56:26 rowlf kernel: svc: socket e0000040fe7b6f80 sendto([e00000404258c000 96... ], 96) = 0 (addr 2501a8c0)
...
> 
> tcpdump confirms the same thing -- packets go in, but they don't come out.
> 

Very helpful details.  
It looks like a simple case of 32-bit parochialism :-)

Does this patch help?
Thanks,
NeilBrown


diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-09-05 13:47:33.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-09-05 13:48:42.000000000 +1000
@@ -376,8 +376,8 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		msg.msg_flags	= MSG_MORE;
 
 		msg.msg_control = &cm;
-		msg.msg_controllen = sizeof(cm);
-		cm.cmh.cmsg_len = sizeof(cm);
+		msg.msg_controllen = CMSG_LEN(sizeof(cm));
+		cm.cmh.cmsg_len = CMSG_LEN(sizeof(cm));
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

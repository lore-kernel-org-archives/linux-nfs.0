From: Peter Astrand <peter@cendio.se>
Subject: NFSv3 ACL status?
Date: Thu, 12 Aug 2004 09:01:39 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0408120858530.14721-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bv9aq-0001XL-Jv
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 00:01:44 -0700
Received: from cheddar.cendio.se ([193.12.253.77] helo=mail.cendio.se)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bv9aq-00049F-5o
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 00:01:44 -0700
To: nfs@lists.sourceforge.net, <acl-devel@bestbits.at>
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


Can someone give an quick overview of the Linux NFSv3 ACL status? The
Linux NFS FAQ at http://nfs.sourceforge.net/ says:

"D3. What does this mean:  svc: unknown program 100227 (me 100003)

A. It refers to a mount request by a Solaris system that is trying to get
ACL information - which linux obviously does not have. "

But: http://acl.bestbits.at/ seems to indicate that ACLs over NFSv3
actually works, and provides patches for 2.6.1, but I can't find any
information about if this patch is really needed for modern kernels
(2.6.7) or modern distributions. Is this patch for the server, client or 
both? 

Also, what about interoperatbility with Solaris?


/Peter Åstrand 




-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: client breaking large synchronous writes into page-sized operations
Date: Tue, 14 Sep 2004 16:55:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF384027ED.2EEEA6E4-ON88256F0F.0081F2A6-88256F0F.0083657E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7N8u-0004mr-An
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 16:55:24 -0700
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C7N8s-0007BE-RZ
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 16:55:24 -0700
To: trond.myklebust@fys.uio.no
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

Hi Trond,

>From the FAQ, the answer to B9 states:
Currently the Linux NFS client has a limitation which prevents it from 
safely generating large synchronous writes. The client breaks large write 
requests into on-the-wire write operations that are no larger than a 
single page to guarantee that write requests arrive on the server's disk 
in byte order (some applications depend on this behavior). Even if you set 
wsize larger than a page, the client will break any application write 
request into page-sized NFS write operations to meet this guarantee.

I was wondering if you could explain what the limitation is.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

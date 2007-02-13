From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: RFC: Improved Zerocopy for NFS
Date: Tue, 13 Feb 2007 17:07:41 +0100
Message-ID: <200702131707.42796.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HH0Co-0001LO-DA
	for nfs@lists.sourceforge.net; Tue, 13 Feb 2007 08:08:34 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HH0Cm-0000tg-2e
	for nfs@lists.sourceforge.net; Tue, 13 Feb 2007 08:08:33 -0800
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l1DG8CpA024549
	for <nfs@lists.sourceforge.net>; Tue, 13 Feb 2007 09:08:12 -0700
Received: from rcsmt251.oracle.com (rcsmt251.oracle.com [148.87.90.196])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l1DFihbC019844
	for <nfs@lists.sourceforge.net>; Tue, 13 Feb 2007 09:08:10 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,

during the last week or so I did some patches to the sunrpc code that
should help reduce the number of memcpy operations we do there.
They implement

 *	IOAT support in the rpc client code
 *	TCP zerocopy in the rpc server code

Both have been lightly tested (the former severely hampered by the lack
of ioat capable hardware, which is why I had to write a "memcpy dma"
module :-)

The code is available from http://oss.oracle.com/~okir/nfs-zerocopy/
Please let me know what you think.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

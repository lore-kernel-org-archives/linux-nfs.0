From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client breaking large synchronous writes into page-sized
 operations
Date: Wed, 15 Sep 2004 11:16:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095239780.7648.1.camel@lade.trondhjem.org>
References: <OF384027ED.2EEEA6E4-ON88256F0F.0081F2A6-88256F0F.0083657E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7Vu8-0008CM-UR
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 02:16:44 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C7Vu7-00046c-4g
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 02:16:44 -0700
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: <OF384027ED.2EEEA6E4-ON88256F0F.0081F2A6-88256F0F.0083657E@us.ibm.com>
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

P=E5 on , 15/09/2004 klokka 01:55, skreiv Bruce Allan:

> I was wondering if you could explain what the limitation is.
>=20

The limitation is that writepage and friends all work using single
pages.

It is therefore not an NFS client limitation, it is a VFS limitation...

Cheers,
 Trond



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

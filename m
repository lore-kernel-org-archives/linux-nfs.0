From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 11:08:28 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079453308.3045.26.camel@lade.trondhjem.org>
References: <8147E1B07201DD41B6B9F0D31E07B38401648904@srv-grp-s07.dev.atos.fr>
	 <039c01c40b5b$cc2f06e0$3f32a8c0@ds.ig.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3H7H-0005M2-Cl
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:08:31 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B3H7G-0000L9-L3
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:08:30 -0800
To: Fabiano Reis <silos.reis@ig.com.br>
In-Reply-To: <039c01c40b5b$cc2f06e0$3f32a8c0@ds.ig.com.br>
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

P=E5 ty , 16/03/2004 klokka 08:37, skreiv Fabiano Reis:
> looks like you are getting the maximum number of nfs operations by
> mountpoint. See nfs.sourceforge.net
>=20
> The maximum nfs operations by mountpoint for kernel < 2.5.47 is 256
>=20
> I=B4m getting the same problem with kernel 2.4.20. I ipgraded a nfs clien=
t to
> kernel 2.6 and I still getting the same problem. Maybe a solution is to
> upgrade the server and client to kernel 2.6 (I didnt tested it yet)

There is a second limit: the RPC client limits the number of RPC
requests it can have outstanding on the wire.

On TCP, that limit is always 16 requests. On UDP, there is a congestion
control algorithm that will reduce that limit dynamically if the network
is losing packets (or if the server is dropping them).

Note: 2.6.5-rc1 contains a patch by Chuck Lever that allows you to
change that upper limit of 16 requests by means of a /proc interface.

Cheers,
 Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

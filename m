From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: F_SETLK failed, file already locked by pid 0
Date: Sun, 22 Aug 2004 20:29:16 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093220956.4718.23.camel@lade.trondhjem.org>
References: <A4B2A13E-F48D-11D8-A02C-000A95C71776@freezone.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bz2iB-0003dx-PC
	for nfs@lists.sourceforge.net; Sun, 22 Aug 2004 17:29:23 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bz2i7-0000iL-ED
	for nfs@lists.sourceforge.net; Sun, 22 Aug 2004 17:29:20 -0700
To: ms419@freezone.co.uk
In-Reply-To: <A4B2A13E-F48D-11D8-A02C-000A95C71776@freezone.co.uk>
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

P=E5 su , 22/08/2004 klokka 18:50, skreiv ms419@freezone.co.uk:
> I suspect locking isn't working:
>=20
> F_SETLK failed, file already locked by pid 0
>=20
> Pointers to diagnostic  information, configuration, & documentation much =
appreciated!

NFS-HOWTO:
	http://nfs.sourceforge.net/nfs-howto/

NFS-FAQ:
	http://nfs.sourceforge.net/

> Why isn't locking working?

No-one will be able to answer this until you give at least a minimum of
details on how your system is set up. For instance, details on how the
network is set up, whether rpc.statd is running as it should, whether
'rpcinfo -p' works from both server to client and from client to server,
etc.

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

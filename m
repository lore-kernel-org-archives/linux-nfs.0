From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 18:04:28 +0100
Message-ID: <20050220170428.GA18102@s>
References: <20050220111312.GA3974@s> <1108908221.27120.26.camel@lade.trondhjem.org> <20050220141037.GA7686@s> <1108913435.27120.40.camel@lade.trondhjem.org> <1108917793.27120.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2uVe-0008ES-5Y
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 09:04:42 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2uVc-0000pk-ET
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 09:04:42 -0800
Received: from mail-mx6.uio.no ([129.240.10.47] ident=[U2FsdGVkX1/xg0c59g6rSseLTO4PkTX0svbTWyNESz8=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2uVX-0005D5-QR
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 18:04:35 +0100
Received: from 160.80-203-48.nextgentel.com ([80.203.48.160] helo=s.hn.org)
	by mail-mx6.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1D2uVV-00050A-L0
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 18:04:33 +0100
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1108917793.27120.43.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

[Trond Myklebust]

> su den 20.02.2005 Klokka 10:30 (-0500) skreiv Trond Myklebust:

>> See if the attached patch doesn't fix things so that your 3rd
>> rpc.statd port stays on the port specified by "-o"...

> Here is the same patch in a slightly cleaner version (it gets
> rid of the redundant comparison)...

Works great -- thanks for fixing this so quickly!

-- 
 Haakon


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

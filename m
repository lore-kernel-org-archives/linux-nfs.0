From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: read(2) hangs on the client side
Date: Wed, 11 May 2005 07:23:42 -0700
Message-ID: <1115821422.13483.0.camel@lade.trondhjem.org>
References: <20050508113343.GA629@fox>
	 <1115556864.11308.1.camel@lade.trondhjem.org> <20050508132127.GA1744@fox>
	 <1115560765.11308.6.camel@lade.trondhjem.org> <20050508143754.GA492@fox>
	 <1115635107.24625.0.camel@lade.trondhjem.org>  <20050509141339.GA3216@fox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVs83-0004Wy-1w
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 07:24:03 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DVs81-00014D-IL
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 07:24:02 -0700
Received: from mail-mx2.uio.no ([129.240.10.30])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DVs7v-0006mL-D9
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 16:23:55 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050509141339.GA3216@fox>
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

m=C3=A5 den 09.05.2005 Klokka 16:13 (+0200) skreiv Haakon Riiser:
> Trond,
>=20
> > Do you have a tcpdump of the traffic?
>=20
> Should I run tcpdump on the server or the client, or perhaps it
> doesn't matter?

Please try on the client first.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

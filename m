From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 16:14:28 -0500
Message-ID: <1101158068.11196.71.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
	 <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr>
	 <1101146906.11196.35.camel@lade.trondhjem.org>
	 <41A236A6.4050104@int-evry.fr>
	 <1101154485.11196.64.camel@lade.trondhjem.org>
	 <02f401c4d0d6$ce19e9c0$2801a8c0@PAULLAPTOP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWLWI-0007h4-Ok
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:14:46 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWLWF-0007rj-0B
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:14:46 -0800
To: Paul Cunningham <paulcunningham@sprintmail.com>
In-Reply-To: <02f401c4d0d6$ce19e9c0$2801a8c0@PAULLAPTOP1>
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

m=E5 den 22.11.2004 Klokka 16:04 (-0500) skreiv Paul Cunningham:

> It has been a few years, but I remember some of the async details.  I
> always=20
> used async for performance reasons, and much testing was performed to
> assure=20
> no data would be lost.  If a client sent an async write to the server,
> the=20
> call could return prior to data being flushed to disk.  The data would
> make=20
> it to disk once the server decided to write it or the client sends in
> a=20
> COMMIT.  At some point in time the client will attempt to close the
> file,=20
> this is when a COMMIT must be sent, the hope is that the server has
> already=20
> written the dirty pages to disk while the client was busy doing other=20
> things, and will respond with an OK quickly.  If any dirty pages
> remain,=20
> they must be flushed prior to responding OK.  Data should never be
> lost as=20
> long as the NFSPROC3_COMMIT procedure is adhered to.
>=20

Sure. This is how the Linux client works. The problem is the "async"
*export* option on the server.

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

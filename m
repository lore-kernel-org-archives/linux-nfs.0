From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: list of patches between 2.6.9 and 2.6.11-rc4
Date: Mon, 21 Feb 2005 19:03:12 -0500
Message-ID: <1109030592.22895.57.camel@lade.trondhjem.org>
References: <200502212335.25502.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3NWV-0002oY-2Z
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 16:03:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D3NWS-00078j-G3
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 16:03:30 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200502212335.25502.bernd-schubert@web.de>
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

m=E5 den 21.02.2005 Klokka 23:35 (+0100) skreiv Bernd Schubert:
> Hello Trond,

The best place to search for NFS client patches that have actually been
merged in is to use the web-based Bitkeeper browser:

http://linux.bkbits.net:8080/linux-2.6/src?nav=3Dindex.html

That allows you to go to each file, and see how recently it has changed,
and which changesets (Bitkeeper-speak for "patches")  affect it.

> The nfs-server for /var is unfs3, but I really think thats a client probl=
em. I=20
> also so far couldn't find something of interest in an ethereal log betwee=
n=20
> the client and server on the unfs3 port.

You should really always be mounting using "nolock" when you are running
against unfs3. Is that what you have normally been using?

Cheers,
  Trond
--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

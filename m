From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client hangs...
Date: Mon, 13 Dec 2004 20:10:09 -0500
Message-ID: <1102986610.10838.5.camel@lade.trondhjem.org>
References: <20041214010503.80556.qmail@web81508.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce1Cm-0000qA-Ta
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:10:20 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ce1Cm-00045s-2e
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:10:20 -0800
To: Ryan Mak <ryanmak@ameritech.net>
In-Reply-To: <20041214010503.80556.qmail@web81508.mail.yahoo.com>
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

m=E5 den 13.12.2004 Klokka 17:05 (-0800) skreiv Ryan Mak:
> oops. the tcpdump was taken on the client.

You sure it wasn't taken on the server?

The pattern indicates that the RPC client is retrying and backing off
exponentially because it is not seeing replies from the server. If
indeed the tcpdump was taken on the client, then something funny is
going on, because that would mean that the networking layer is seeing
the packets, but the RPC layer is not receiving them.

Cheers,
  Trond

>=20
> --- Trond Myklebust <trond.myklebust@fys.uio.no>
> wrote:
>=20
> > m den 13.12.2004 Klokka 16:50 (-0800) skreiv Ryan
> > Mak:
> > > Hi.
> > >=20
> > > I am currently experiencing a hanging problem when
> > I
> > > try to either 'ls' or 'vi' on a successfully
> > mounted
> > > directory. I am using redhat 8.0, kernel version
> > > 2.4.20-28.8, nfs-utils version nfs-utils-1.0.1-2.
> > >=20
> > > enclosed is a tcpdump which shows retries from the
> > > client despite an immediate ACK from the server.=20
> >=20
> > Was that tcpdump taken on the server or the client?
> >=20
> > Cheers,
> >   Trond
> > --=20
> > Trond Myklebust <trond.myklebust@fys.uio.no>
> >=20
> >=20
>=20
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

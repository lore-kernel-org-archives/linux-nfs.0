From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: FYI: readdirplus responsiveness problem after 2.4 -> 2.6 client upgrade
Date: Tue, 12 Jul 2005 17:56:01 +0200
Message-ID: <20050712155601.GA30553@janus>
References: <20050711165147.GB20471@janus> <1121102236.8056.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsN7B-0008Ol-J1
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 08:56:09 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsN7A-0002DX-Di
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 08:56:09 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121102236.8056.17.camel@lade.trondhjem.org>
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

On Mon, Jul 11, 2005 at 01:17:16PM -0400, Trond Myklebust wrote:
> m=E5 den 11.07.2005 Klokka 18:51 (+0200) skreiv Frank van Maarseveen:
> > In practice there are a significant number of cases without retransmiss=
ion
> > when the server appears unresponsive to the user with readdirplus. Since
> > it is induced by bash name completion it is very visible to the user:
> > occasionally command-completion takes 3..10 seconds now to give an idea.
> > Name completion for arguments is hurt too sometimes.
>=20
> I suppose you could mask out NFS_CAP_READDIRPLUS on the client, but it
> sounds very strange that the OSF implementation should be so incredibly
> slow. Is there nothing in the administrators manual about tuning this
> sort of operation?

Maybe. I'm not an tru64 expert. But I do know that the server in
question is underpowered, e.g. lookups, getattr are a bit slow at times
as well. Anyway, the "user experience" seems better with readdirplus
disabled on the client so I decided to do that.

--=20
Frank


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

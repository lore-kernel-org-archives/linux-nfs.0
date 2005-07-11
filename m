From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: FYI: readdirplus responsiveness problem after 2.4 -> 2.6
	client upgrade
Date: Mon, 11 Jul 2005 13:17:16 -0400
Message-ID: <1121102236.8056.17.camel@lade.trondhjem.org>
References: <20050711165147.GB20471@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds1uP-0004eI-Ia
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 10:17:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds1uO-0002C4-4Y
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 10:17:33 -0700
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20050711165147.GB20471@janus>
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

m=C3=A5 den 11.07.2005 Klokka 18:51 (+0200) skreiv Frank van Maarseveen:
> In practice there are a significant number of cases without retransmissio=
n
> when the server appears unresponsive to the user with readdirplus. Since
> it is induced by bash name completion it is very visible to the user:
> occasionally command-completion takes 3..10 seconds now to give an idea.
> Name completion for arguments is hurt too sometimes.
>=20
> A quick peek into the source suggested:
>=20
> -	reduce NFS_LIMIT_READDIRPLUS?
> -	"recognize" name-completion kind of use and revert
> 	NFS_INO_ADVISE_RDPLUS?
>=20
> Other options (except replacing the server)?

I suppose you could mask out NFS_CAP_READDIRPLUS on the client, but it
sounds very strange that the OSF implementation should be so incredibly
slow. Is there nothing in the administrators manual about tuning this
sort of operation?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

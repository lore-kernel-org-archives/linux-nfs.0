From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: link(2) - atomic?
Date: Thu, 17 Jun 2004 19:40:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1087515632.10308.0.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0406171128570.31212@harp.ngdc.noaa.gov>
	 <1087509279.4042.101.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406171650060.520@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb6Uq-0003JA-C7
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 16:40:40 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Bb6Un-000448-3i
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 16:40:37 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406171650060.520@harp.ngdc.noaa.gov>
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

P=E5 to , 17/06/2004 klokka 18:52, skreiv Ara.T.Howard:
> > Ditto for open (on Linux 2.6 clients only) and symlink().
>=20
> do you mean
>=20
>    0)
>      open    =3D> atomic 2.6 only
>      symlink =3D> atomic 2.6 only
>=20
> or
>=20
>    1)
>      open    =3D> atomic 2.6 only
>      symlink =3D> atomic all kernels

Symlink is atomic on all kernels. open(O_EXCL) is atomic on 2.6 only (it
is not actually implemented in 2.4.x).

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

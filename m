From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 09 Dec 2004 11:34:40 -0800
Message-ID: <1102620880.3784.3.camel@tesuji.nac.uci.edu>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
	 <41B74551.5040908@sun.com>  <20041209113107.GE15055@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-dc78lvW4+VszHg6IbRli"
Cc: strombrg@dcs.nac.uci.edu, Mike Waychison <Michael.Waychison@Sun.COM>,
        "Lever, Charles" <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcU3u-00081I-U5
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 11:34:50 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CcU3t-0003TV-OE
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 11:34:50 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041209113107.GE15055@suse.de>
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


--=-dc78lvW4+VszHg6IbRli
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-12-09 at 12:31 +0100, Olaf Kirch wrote:
> On Wed, Dec 08, 2004 at 01:17:53PM -0500, Mike Waychison wrote:
> > This has been bugging me for a while.  The fact that we are limitting
> > ourselves to a single nfs mount per port.  From what I can tell, Solari=
s
> > shares the transports between nfs mounts from the same server and saves
> > themselves a lot of trouble with running out of port numbers in doing s=
o.
>=20
> Shouldn't we allow NFS mounts to use non-privileged ports? Many
> environments don't really care about the "security" provided by privilege=
d
> ports, but would be more than happy if they can run with a few hundred
> NFS mounts

IMO, this is a good time to apply the principle: "Be liberal in what you
accept, and conservative in what you send".

Last I heard, windows didn't even have a concept of a reserved port.

When I wrote a BSD-compatible printsystem in python, I made it accept
connections from any port, but generate connections only from reserved
ports.

It'd probably be worthwhile to have options to make NFS (and my
printsystem) generate any port (not just reserved ones), and accept only
reserved ports - but the default probably should be to accept any port,
and send only reserved ports - not because reserved ports are effective
at all, but because it'll avoid never ending questions about why NFS
isn't working.



--=-dc78lvW4+VszHg6IbRli
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBuKjPo0feVm00f/8RAsygAJ9q8Bl3btA7Qc9Ewe4vWDLyFmsAEACfVSTm
jUau4A1PlO0GSvddRhVB5pI=
=e3uz
-----END PGP SIGNATURE-----

--=-dc78lvW4+VszHg6IbRli--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

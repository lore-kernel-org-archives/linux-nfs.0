From: Garrick Staples <garrick@usc.edu>
Subject: Re: Searching NFS Archives
Date: Tue, 10 Jan 2006 11:35:01 -0800
Message-ID: <20060110193501.GE29622@polop.usc.edu>
References: <1136907278.6837.12.camel@L10-WS-AWS1.AWS> <200601101645.14166.vincent.roqueta@ext.bull.net> <1136910191.6837.49.camel@L10-WS-AWS1.AWS>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uIqYzFIsIr/FOPFK"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwPGu-0005N7-Tj
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 11:35:08 -0800
Received: from polop.usc.edu ([128.125.10.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EwPGt-0004pd-O3
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 11:35:08 -0800
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id k0AJZ1KI031368
	for <nfs@lists.sourceforge.net>; Tue, 10 Jan 2006 11:35:01 -0800
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id k0AJZ1R0031366
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 11:35:01 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1136910191.6837.49.camel@L10-WS-AWS1.AWS>
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


--uIqYzFIsIr/FOPFK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 10, 2006 at 05:23:10PM +0100, Al Active alleged:
> Thanx for answering Vincent
>=20
> On Tue, 2006-01-10 at 16:45 +0100, Vincent Roqueta wrote:
> > Le Mardi 10 Janvier 2006 16:34, Al Active a ??crit :
> > works for me:
> > http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs
>=20
> I still can't open it ??
>=20
> >=20
> > I don't understand what you are trying to do?
> > Samba clients can't access a NFS server...
>=20
> No, I have one central SuSE Linux 10.0 server cluster for all data. It
> exports NFS shares to a number of NFS-Servers. The NFS-Servers are also
> clusters with heartbeat; one for Samba, another for Apache, another for
> ERP. The Samba server, for eg. receives all data shares from the central
> data cluster for a windows network over the NFS-Shares. =20

Be careful with the terminology.  It is confusing to call machines that
don't serve NFS, "NFS-Servers."  The SuSE box is the "NFS server", the
other machines are "NFS clients" and "Samba servers".

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--uIqYzFIsIr/FOPFK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFDxAxl0SBUxJbm9HMRAqKEAJ9kN1GD7Fl3aPLCgcZuUQGhg6asYQCfQ2lC
EXrUTpYqvBiwIx+TvqcqvS8=
=MLCj
-----END PGP SIGNATURE-----

--uIqYzFIsIr/FOPFK--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

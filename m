From: Jordi Mallach <jordi@debian.org>
Subject: Re: [chip@debian.org: Debian Bug#203918 - statd request on eth interface, not localhost?]
Date: Thu, 21 Aug 2003 09:58:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821075826.GA27391@nubol.int.oskuro.net>
References: <20030812152154.GQ24349@perlsupport.com> <16185.47443.33945.603458@gargle.gargle.HOWL> <20030813082216.GA14015@nubol.int.oskuro.net> <20030820175951.GB3639@perlsupport.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	203918-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 115.red-213-96-69.pooles.rima-tde.net ([213.96.69.115] helo=natura.oskuro.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pkL5-0008Ug-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 00:58:36 -0700
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: <20030820175951.GB3639@perlsupport.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2003 at 01:59:51PM -0400, Chip Salzenberg wrote:
> So, what news?

News are that I can't compile 2.6.0-test3, so I have no more info :(

> If you're still getting invalid statd requests from an IP other than
> 127.0.0.1, they're not from the kernel.  Can you use tcpdump to find
> out where the statd requests are coming from?

=46rom the server's log:

Aug 20 02:02:24 natura rpc.statd[467]: Call to statd from non-local host 21=
3.96.69.115
Aug 20 02:02:24 natura rpc.statd[467]: STAT_FAIL to natura for SM_MON of 19=
2.168.1.3

So, yes.. I'm still getting those 2.5 minutes after the apt-get cronjob
starts.

I have never used tcpdump more than to play a little, so I could use
some pointers about what I should look at.

Thanks,
Jordi
--=20
Jordi Mallach P=E9rez  --  Debian developer     http://www.debian.org/
jordi@sindominio.net     jordi@debian.org     http://www.sindominio.net/
GnuPG public key information available at http://oskuro.net/~jordi/

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/RHuiJYSUupF6Il4RAhEvAJ4hiGGIPEk+5fmrd1qDJRwZmm5A/gCePipB
B4ukdIMI3aveXHBaqurC4TQ=
=yB0w
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

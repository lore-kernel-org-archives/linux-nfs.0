From: Pierre Ossman <pierre-list-vCPtPcF4ZGuHXe+LvDLADg@public.gmane.org>
Subject: Re: Different options for subdir? Possible?
Date: Tue, 18 May 2010 19:34:45 +0200
Message-ID: <20100518193445.0c8dbc17@mjolnir.ossman.eu>
References: <20100515153104.51f5e4ab@mjolnir.ossman.eu>
	<20100517204947.GC5232@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-16716-1274204087-0001-2"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:43771 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757704Ab0ERRev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 13:34:51 -0400
In-Reply-To: <20100517204947.GC5232@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-16716-1274204087-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 17 May 2010 16:49:47 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, May 15, 2010 at 03:31:04PM +0200, Pierre Ossman wrote:
> > I'd like to export the filesystem /exports as ro, but the
> > subdir /exports/dump as rw. I can't seem to get it to work though, so
> > before I start digging deeper I figured I might ask if this is even
> > possible? :)
>=20
> If the "dump" subdirectory is a subdirectory of the same filesystem (not
> a mountpoint), and if you're using NFSv4 (or v2/v3 with crossmnt), the
> client will continue to use the export options on the parent directory.
>=20

Hmm... client? Can't say I'm intimate with the NFS protocol, but access
permissions like this seems like a server decision.

> Also, note that it's relatively easy for someone with access to the
> network to treat all of /exports as rw.

Even with subtree check?

> In general, export points that aren't mountpoints are not usually a good
> idea.

Fair enough. I'll have to figure something else out.

Thanks
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--=_freyr.ossman.eu-16716-1274204087-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.13 (GNU/Linux)

iEYEARECAAYFAkvyz7cACgkQ7b8eESbyJLiuhgCeI+qh7FeOb2bP9wFjmvOZdZhE
M9oAn1OAQ13uur7b/yMDP/43EPVoI6Xy
=6Wz+
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-16716-1274204087-0001-2--

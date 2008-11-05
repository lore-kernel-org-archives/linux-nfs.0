From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: gssapi and nfs4
Date: Wed, 05 Nov 2008 00:25:29 -0500
Message-ID: <1225862729.13506.8.camel@pc.interlinx.bc.ca>
References: <1225813410.2247.279.camel@brian-laptop>
	 <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com>
	 <1225824797.2247.345.camel@brian-laptop>
	 <20081104224817.GB16121@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-nmHEMhDRFK0iWtxrK+r7"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:1848 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbYKEFZk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 00:25:40 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 89E712803
	for <linux-nfs@vger.kernel.org>; Wed,  5 Nov 2008 00:25:38 -0500 (EST)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 69F45800A
	for <linux-nfs@vger.kernel.org>; Wed,  5 Nov 2008 00:25:34 -0500 (EST)
In-Reply-To: <20081104224817.GB16121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-nmHEMhDRFK0iWtxrK+r7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-11-04 at 17:48 -0500, J. Bruce Fields wrote:=20
>=20
> You can still vary ro/rw based on machine or security flavor; e.g.
>=20
> 	/home	foo(sec=3Dkrb5,ro)
> 	/home	bar(sec=3Dkrb5,rw)

Excellent.

> or
>=20
> 	/home	foo(ro,sec=3Dkrb5,rw)
>=20
> (readable by all users, writeable only by krb5 users).

Ahhh.  Very interesting.

> This should all
> be documented by "man exports".

Yes, it appears to be.  My use of gss/krb5(...) was from some "howto"s
that I found on the web.  Seems they are tad dated.


> > I did notice the bit of text about the single pseudo filesystem.  Given
> > that on my server, I exported a number of filesystems, including / to
> > privileged (I'm in a very small and trusted environment) clients, it
> > seemed natural to just set / to fsid 0.  I also exported the few other
> > exports I wanted some nfs4 clients to mount as such:
> >=20
> > /               gss/krb5i(rw,insecure,sync,wdelay,no_subtree_check,no_r=
oot_squash,fsid=3D0,crossmnt,anonuid=3D65534,anongid=3D65534)
> > /home           gss/krb5i(rw,no_root_squash,sync,subtree_check,anonuid=
=3D65534,anongid=3D65534)
> > /mnt/data       gss/krb5i(rw,sync,subtree_check,crossmnt,anonuid=3D6553=
4,anongid=3D65534)
> > /mnt/data/photos gss/krb5i(rw,sync,subtree_check,anonuid=3D65534,anongi=
d=3D65534)
> >=20
> > where those are all on different filesystems on the server.  I'm
> > starting to feel like this is not how it's supposed to be done.
>=20
> That'll work--but do you really want "/" to be accessible (writeable,
> even!) over nfs?

Writable, probably not, not for most anyway.  A very select few,
perhaps.  But still, probably not even readable for most.  So how to
solve?  Not export / as the pseudo filesystem?  Or use an ip/netmask
that makes it impossible to match, or as the one bit of text I read
offered, bind mount everything you want to export into your "export"
tree?  This last option seems a bit cumbersome given that everything I
want to export is already mounted and available under /.

Is there any way to limit/match on krb5 principals rather than IPs?

So in the situation of exporting / as fsid 0 (but this would be equally
applicable to an "/export" configuration that bind mounted a filesystem
under /export and then bind mounted a filesystem under that) given that
I have other filesystems mounted under / that I want to export as well,
(i.e. /usr) it's seemed necessary to use the "crossmnt" option on the
fsid 0 export.  Is this correct?

So if I do export / as fsid=3D0,ro my guess is that I have to also export
any subdirs that I want to make "rw" separately, and mount them
separately on the client.  i.e.

/	10.75.22.0/24(sec=3Dkrb5,ro,insecure,sync,wdelay,no_subtree_check,root_sq=
uash,fsid=3D0,crossmnt)
/home   10.75.22.0/24(sec=3Dkrb5,rw,no_root_squash,sync,no_subtree_check)
/d      10.75.22.0/24(sec=3Dkrb5,rw,no_root_squash,sync,no_subtree_check,cr=
ossmnt)
/d/sub  pc(sec=3Dkrb5,rw,no_root_squash,sync,no_subtree_check)

and on the clinet:

pc # mount -t nfs4 -o sec=3Dkrb5 server:/ /mnt/server
pc # mount -t nfs4 -o sec=3Dkrb5 server:/home /mnt/server/home
pc # mount -t nfs4 -o sec=3Dkrb5 server:/d /d
pc # mount -t nfs4 -o sec=3Dkrb5 server:/d/sub /d/sub

To have /home rw under /mnt/server.  It would be there but ro without
the second mount, yes?

It also appears that for the above case of /d and /d/sub I need the
crossmnt option on /d or I don't see anything in /d/sub even though I've
exported and mounted it individually.  Does this seem like the expected
behaviour or a bug?  It's important to be able to do because I might
want to be able to export /d to certain hosts without giving them access
to mountpoints within /d as I have done above with /d/sub and pc.  If I
use crossmnt which my experience is showing I need, then /d/sub is
exposed to all of 10.75.22.0/24 which is not what I want.

Thanx,
b.




--=-nmHEMhDRFK0iWtxrK+r7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkRLi8ACgkQl3EQlGLyuXAqzQCgkBmeqUC9dSJGv6xPNGActR5u
Q4cAoJ9SjAnZski0caj+hdJCtpi3pK8N
=udJi
-----END PGP SIGNATURE-----

--=-nmHEMhDRFK0iWtxrK+r7--


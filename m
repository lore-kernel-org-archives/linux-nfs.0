Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58382 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbaAEXas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jan 2014 18:30:48 -0500
Date: Mon, 6 Jan 2014 10:30:36 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        simo@redhat.com, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140106103036.1f7ebc5f@notabene.brown>
In-Reply-To: <20140105225421.GA24059@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
	<1388579314-15255-2-git-send-email-jlayton@redhat.com>
	<20140102212149.GC28219@fieldses.org>
	<20140106093744.14fc3670@notabene.brown>
	<20140105225421.GA24059@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/pu7R8eBWrwv3jg=SfooE4BU"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/pu7R8eBWrwv3jg=SfooE4BU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 5 Jan 2014 17:54:21 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Jan 06, 2014 at 09:37:44AM +1100, NeilBrown wrote:
> > On Thu, 2 Jan 2014 16:21:50 -0500 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> > > > It doesn't make much sense to make reads from this procfile hang. As
> > > > far as I can tell, only gssproxy itself will open this file and it
> > > > never reads from it. Change it to just give the present setting of
> > > > sn->use_gss_proxy without waiting for anything.
> > >=20
> > > I think my *only* reason for doing this was to give a simple way to w=
ait
> > > for gss-proxy to start (just wait for a read to return).
> > >=20
> > > As long as gss-proxy has some way to say "I'm up and running", and as
> > > long as that comes after writing to use-gss-proxy, we're fine.
> > >=20
> >=20
> >=20
> > Only tangentially related to the above email .....
> >=20
> > I had a look at this new-fangled gssproxy thing and while it mostly see=
ms
> > like a good idea, I find the hard-coding of "/var/run/gssproxy.sock" in=
 the
> > kernel source .... disturbing.
> > You never know when some user-space might want to change that - maybe to
> > "/run/gssproxy.sock" (unlikely I know - but possible).
> >=20
> > Probably the easiest would be to hand the path to the kernel.
> >=20
> > e.g. instead  of writing '1' to "use-gss-proxy", we could=20
> >   echo /my/path/gss-proxy-sock > /proc/net/rpc/use-gss-proxy
> >=20
> > Then you could even use an 'abstract' socket name if you wanted. i.e. o=
ne
> > starting with a nul and which doesn't exist anywhere in the filesystem.
> > I would feel a lot more comfortable with that than with the current
> > hard-coding.
>=20
> See also RPCBIND_SOCK_PATHNAME.  (I *think* that's completely hardcoded,
> not just a default.)

Arrgghhh!! (Hi Chuck.  Yes, I agree it is "undesirable in the long term").

>=20
> I get the general principle.  I have a hard time seeing how it would be
> a problem in practice.

One day some distro will decide that it is time to get rid of the legacy
symlink (or bind mount) of /var/run -> /run.  And they will test it out and
everything will work fine.  So they will commit to it.
And then when they release it, their customers will discover that NFS doesn=
't
work properly with gss (because the distro forgot to test that).

>=20
> If we wanted to do as you suggest, I suppose we could even special-case
> the string "1" (at least for a while) to make the change
> backwards-compatible.

I like the idea.

>=20
> I'd like to see the same argument made for the rpcbind case.

I hereby make said argument.  Hardcoding path names in the kernel is
Just-Wrong(TM).  Even /sbin/init is configurable.

NeilBrown


>=20
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/pu7R8eBWrwv3jg=SfooE4BU
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUsnrHDnsnt1WYoG5AQI8Zg/7BdmfXCFZIEbluhc6XZWiOc01qry4gYDK
N/7ONf/McYJcZSFZ6RY6p6KGyhM3+adt9yBTwyJCC4ojTAWs2m/JM2tODXaGoouF
Gbp1ZcK/VdJQNlSFt9B282pssCeP/eeYz6+jtnrJUmXTNjYtncqwi05M7/KC65Zq
lY83vvcGzIQL9qdUzEuMHhFC9ad0EeDBqShXMTrF9rK/seGvvKYBEEwgJk0vHx5G
BhDafZDNXissrI7zeYvd25zJC2LdvAlcu3dXDic9tMnMe7yFzUUnB1OCRt2SU52f
QA9TU5LfyYWvkHhhYI6pwLuKPfRyqLhaJZtxpD/mOJbdpJt1/RoFGS5yG1SpcrGf
e/8o3h1N1ylMGvDJcL0nlQzLB2Cn0ADEOlRVJqGh2sMXj9wHvuzwpzdDbXenTUjo
f7pFJngXJDsMkvMkzFSWBaudzprdn2Kd4GiQxZaYAFQBRSV1y5sDOxHQCnGAcwLi
zsuBbjrsUT1aFBV+jPvUK9keEFGunP8BZvwQrpb1/PJcGFpl2C5r92acgQc7D/tx
W/mlNxyOrE0NYAuAI6Kh05seEvngwfuaPztVmx/m3/zao4boEf53YtaoEJOVuDGI
Oi/RHEz8rpEJhoeHGcq8/PFNJHdJ171FdlDyR4EfPF12pH/mtY//PlA1rpCK27RH
xLbXbeTaTRc=
=sgO7
-----END PGP SIGNATURE-----

--Sig_/pu7R8eBWrwv3jg=SfooE4BU--

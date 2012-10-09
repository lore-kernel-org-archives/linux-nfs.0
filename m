Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49695 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755252Ab2JIAdi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 20:33:38 -0400
Date: Tue, 9 Oct 2012 11:33:42 +1100
From: NeilBrown <neilb@suse.de>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121009113342.018a6d0c@notabene.brown>
In-Reply-To: <20121008152647.GA15534@us.ibm.com>
References: <20121002143334.GA1435@fieldses.org>
	<20121003134629.72557522@notabene.brown>
	<20121003151349.GD14313@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
	<20121003162728.GE14313@fieldses.org>
	<20121004084659.38632320@notabene.brown>
	<20121004160739.GA4693@fieldses.org>
	<20121008170304.37dc6ae9@notabene.brown>
	<20121008135452.GA14785@us.ibm.com>
	<20121008141839.GA27230@fieldses.org>
	<20121008152647.GA15534@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=blEa0ujy/zWpJEqAN.K1HK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=blEa0ujy/zWpJEqAN.K1HK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 8 Oct 2012 10:26:47 -0500 Malahal Naineni <malahal@us.ibm.com> wrot=
e:

> J. Bruce Fields [bfields@fieldses.org] wrote:
> > On Mon, Oct 08, 2012 at 08:54:52AM -0500, Malahal Naineni wrote:
> > > NeilBrown [neilb@suse.de] wrote:
> > > > Mount with NFSv4 and it takes about the same.  However:
> > > >=20
> > > > .....
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2974
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2975
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2976
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2977
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2978
> > > > drwxr-xr-x 2 u2979      root 4096 Oct  8 16:19 2979
> > > > drwxr-xr-x 2 u2980      root 4096 Oct  8 16:19 2980
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2981
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2982
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2983
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2984
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2985
> > > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2986
> > > > ....
> > > >=20
> > > >=20
> > > > tcpdump shows the server is returning the write stuff, but somethin=
g if going
> > > > wrong on the client.  I've tried unmounting/remounting and killing/=
restarting
> > > > rpc.idmapd.
> > >=20
> > > As you know 4294967294 is (-2, nfs nobody), I have seen this issue wi=
th NFS
> > > server sending numeric ids by default in AUTH_SYS (commit
> > > e9541ce8efc22c233a045f091c2b969923709038), but the client can't handle
> > > them (lack of commit 5cf36cfdc8caa2724738ad0842c5c3dd02f309dc in clie=
nt
> > > code).
> > >=20
> > > I hand patched server commit, but my client was an older one. That is
> > > how I got into my issue. Not sure, if you are running into a similar
> > > issue.
> >=20
> > Oh, could be--but then why would some of the id's still be mapped
> > correctly?
>=20
> Wild guess, those objects are created by client and didn't get their
> attributes updated yet from server???
>=20
> FYI, a co-worker here had RHEL6.3 server and RHEL6.2 client that
> exhibited this nobody issue with NFSv4.
>=20
> Regards, Malahal.

I think the original cause of my problem was that I had inconsistent settin=
gs
for 'Domain' in 'idmapd.conf'.  That seems to have resulted in 'nobody'
entries being cached which I now cannot flush.

I'm running a 3.5 kernel on the client, so the issues you mentioned won't be
affecting me.

Thanks,
NeilBrown

--Sig_/=blEa0ujy/zWpJEqAN.K1HK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUHNw5jnsnt1WYoG5AQJrMQ/+K/5uJuHR0qHbxakCoa7rb8OvmGnhYNcx
xa3eCmZmMFuIrF3qXQaDxf4WKtvpyCzwS0TZtTh55bI3wL0/PrC16hd2LaCvM+lW
dw4GRBgf1K0M7DJomXOkPcmUs8WO/h6GeN0oa5Szame82hPe2kSAxPJWChX6kyt6
XutYzkv9xBToU9g3vgL8OAhXOXCiOHJfGa39KoV7pGO4Q6bZZDZACNC8sJeBfROT
8A2mSyA3Mkgmz6G406AzXa9SZ7t8arQWWyNjz+vNuXXXr/lEZBJM0l1IobCLxiOF
xWxeUWjZDP/dSdM1rOz7xVRsAFIuGC5R+PMW74Or3DArk0VcuItAEMtYeluCS+TX
zVjv3Vtiz2xtra3w+sypQrhe79JWDJiDBV1Zn00ZkZn4d6/yy63K6qvVf85lMIBG
Od/ukmMNKatFSwEFz4kL53tAxS1ZizavZDwQJgp6Htc8B/lD4TQHyhP9ntYJs4aZ
pStfnAoEI0Ost7/X/MM45Wdq9+ujdJ0xQ6WVIprhCF0vdc8d8FJMC6wT/xnonask
98iiriNangW6OlNdnUnlqV0qMdTyI1VN7vEk3V9ABXYJO6TvkbXJ3+bP9QOCXBhb
09IVYgqky7Yd1CSYoJK5UJO1qnfRyfgqCLrqAoJtygTwggQL6rFnZCrzN2uyj0Hp
sH6MHJhymic=
=dUAy
-----END PGP SIGNATURE-----

--Sig_/=blEa0ujy/zWpJEqAN.K1HK--

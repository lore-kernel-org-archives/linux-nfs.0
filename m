Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41516 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbaBYBhO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Feb 2014 20:37:14 -0500
Date: Tue, 25 Feb 2014 12:37:01 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Dickson Steve <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid
 needing to write to /proc
Message-ID: <20140225123701.08c59745@notabene.brown>
In-Reply-To: <33021BB9-598C-4A65-B386-BE230E91894F@primarydata.com>
References: <20140220063616.6548.42556.stgit@notabene.brown>
	<33021BB9-598C-4A65-B386-BE230E91894F@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/GEahy6Q6hhAcfdiR.JBldcQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GEahy6Q6hhAcfdiR.JBldcQ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 20 Feb 2014 08:11:47 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

>=20
> On Feb 20, 2014, at 1:36, Neil Brown <neilb@suse.de> wrote:
>=20
> > There are a number of NFS-related setting that currently must be set
> > by writing to various files under /proc.
> > This is a bit clumsy, particularly for systemd unit files.
> >=20
> > So this series adds options to a number of commands where relevant.
> >=20
> > The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortabl=
e with.
> > The third (nlm grace time) I think is probably right but if someone can=
 argue
> > an alternate approach I'm unlikely to resist.
> > The fourth is .... uhm.  You better look yourself.
> >=20
> > Part of me thinks that nlm port numbers should be set in /etc/sysctl.co=
nf (or sysctl.d)
> > and /etc/modprobe.d should have something like
> >=20
> > install lockd  sysctl -p /etc/sysctl.d/lockd
> >=20
> > but last time I tried that it broke "modprobe --show-depends".
> > Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sys=
ctl.d/lockd
> >=20
> > Thoughts?
>=20
> Why not just do most of this at module load time with something like "mod=
probe lockd lockd.nlm_grace_period=3D<nsecs> lockd.nlm_tcpport=3D<portnr> =
=E2=80=A6=E2=80=9D?
> Better yet, add/edit appropriate entries in /etc/modprobe.conf.d at syste=
m setup time.
>=20

Adding entries to /etc/modprobe.conf.d doesn't help if nfs is compiled in to
the base kernel.
Conversely, adding entries to /etc/sysctl.d doesn't help if nfs is a module.
You could conceivable do both (for those few values that are available both
as module parameters and sysctl settings) but that is clumsy and error pron=
e.

Your argument could equally well apply to setting the NFS versions that nfsd
supports, but we have explicit command-line arguments for that.

Due to the highly ad-hoc collection of configuration settings and different
ways to set them and rules for when they are set, I think it is best to have
the settings imposed by code we control rather than requiring a similarly
ad-hoc collection of additions to various configuration files in various
directories.

Ultimately I would like all nfs-utils daemons to take settings out
of /etc/sysconfig/nfs (either by reading it directly, or having systemd/bash
load it into the environment, then the utils using getenv()), so that one
file (which multiple distros already work with) can configure most of
nfs-utils.  This is a step in that direction with (I think) immediate rewar=
ds.

Thanks,

NeilBrown

--Sig_/GEahy6Q6hhAcfdiR.JBldcQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwvzvTnsnt1WYoG5AQLdaQ/+MEWTipJ5WwCaaLFNP9XK8jmS+YiHBUKa
F4Sa9ixjPatxa3MQG+jK3vipVu/tbsYvP/X2OLhhKgQvSrTqlqu9SIz/3d7s97He
I4KikFxOXeII9rEN/UKfUT3yf0bWDj0s0V0gSThFUc4duoEXcLxqYZ6AekNK0uzC
mwsUESBY2eORMivfQjHtTdS8mFuxkkulnErTtip0dP9DTA8/0TL4diku3MJUOHqE
L+VAu+zpgNLgPlOoDQlVwn+Ye4Q4V9Qqua8NSHaNJSvfiJ731ZEpbHwVAQmikBbi
UgX8S2rxn2eDlj/87dJcPDitHcxCoHaz+h1KVOt2oSCrvBV+uKiMREL6aDvKdcae
2oYbzP7+aIzaSjSqldpV17SCelTfKRiQZk0OzIRhZUx46qrdXpUf0NKPL2xwgCe4
5EoYBDDZG/4+Or/j6NqkYZOHuWXAh2qc86eaNU51JC2gfkGWGDq1onCoW1U8zK1U
MTsq0HAm+Uf953hO75I2Dkr0meQdN+4uJpEHmekD6OtChfbRvlghiUWXPdsZDfSr
b1aEnbbMKK4LdpoO+TnYtMHspy0F5Xedhwvk+BPWSdLPKPDV1qbIoUJyhugJ1hi0
0WRRDF+9IvAaZR4jnygCutk+wnUZX+G8X+yzpKAhRSKd28tnl/J5ZxvFygMBar+h
sJ0W2SG3MXQ=
=GRZc
-----END PGP SIGNATURE-----

--Sig_/GEahy6Q6hhAcfdiR.JBldcQ--

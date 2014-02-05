Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41918 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752576AbaBEDJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 22:09:19 -0500
Date: Wed, 5 Feb 2014 14:09:06 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        simo@redhat.com
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140205140906.0b3ba9fd@notabene.brown>
In-Reply-To: <20140204162052.GA5295@fieldses.org>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<20140204093452.7b6d7c7d@notabene.brown>
	<20140204162052.GA5295@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/DFr9hq6WTRAcvXWuECJr5rG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/DFr9hq6WTRAcvXWuECJr5rG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 4 Feb 2014 11:20:52 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
> > On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com> wr=
ote:
> > > Also how does gss-proxy come to play in all this? Maybe we=20
> > > just use  gss-proxy by default and retire rpc.svcgssd.
> >=20
> > I haven't really be following and so am only dimly aware of gss-proxy.
> > It's a replacement for rpc.svcgssd - right?
> > So we should get it to start in the same circumstances as rpc.svcgssd?
> >=20
> > Is there some easy test - eg something existing in the filesystem - tha=
t we
> > could use to see if the kernel supports gss-proxy ?
>=20
> There's a /proc/net/rpc/use-gss-proxy file.
>=20
> (But doesn't gss-proxy have users other than nfsd?)

So presumably gss-proxy would come with its own unit file (looks ... oh yes,
it does. awesome), and we only want to start rpc.svcgssd if:
  - gss-proxy is not active
  - /etc/krpb5.keytab is present.

The second is easy to test in a unit file, an 'and' is generally trivial, b=
ut
testing if another unit is *not* present is not.
There is "Requisite" to test if it is, but you cannot do
    "Requisite=3D!gssproxy.service"
or
    "ConditionUnitStarted=3D!gssproxy.service"
or anything similar that I can find.

"Conflicts=3Dgss-proxy.service" is closest, but that might cause
gss-proxy.service to stop.

Maybe we have to manage testing the .pid file thus:

   After=3Dgssproxy.service
   ConditionPathExists=3D|!@localstatedir@/run/gssproxy.pid
   ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy
   ConditionPathExists=3D/etc/krb5.keytab

so we wait until the gssproxy.service has started if it will be starting at
all, then look for the pid file and if it is missing, or if use-gss-proxy is
missing, we run rpc.svcgssd, providing /etc/krb5.keytab is present.

>=20
> > Also, I've been wondering if we could avoid the need to explicitly enab=
le
> > the gss stuff by gating it on the existence of /etc/krb5.keytab.
> > Do you think that would be reasonable?
>=20
> That would be great.  I hate that people have to care about these
> support daemons, they should just be started automatically when they're
> needed.
>=20
> Is /etc/krb5.keytab the best indicator?

I was hoping you would tell me. :-)

It occurred to me as a good test when I tried running rpc.svcgssd in a fresh
VM and it wouldn't start.  I eventually found the error message complaining
that it couldn't find that file.

It isn't perfect as an empty /etc/krb5.keytab will still result in failure
and exit.  However if a sysadmin has created a keytab and is using NFS, it
seems reasonable to be ready to provide gss services.

rpc.gssd doesn't fail in the same way, but it does complain if the file
doesn't exist, so I suspect it is at least a good indicator.

The only thing that bothers me is that gssd is theoretically more general
than krb5.  However as the reality seems to be that it is exactly krb5, I
don't let that bother me too much.

>=20
> Simplest might be to start unconditionally and just not care if it
> fails.  Or is there a problem cluttering up logs with unimportant
> failures?

More a problem with starting things that aren't necessary, and possibly
leaving them running.
Every process you start adds a little to the boot time.  We only get the be=
st
experience if everyone contributes a little bit, no matter how little.
Also, every running process theoretically adds the to the attack service.
So some people will definitely not want these processes to be started.  If =
we
make it really easy for them, I think that is a good thing.
i.e. I agree with SteveD:=20
> I think we want to stay away (and move away) from unconditionally
> starting anything...=20

Thanks,
NeilBrown




--Sig_/DFr9hq6WTRAcvXWuECJr5rG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvGrUjnsnt1WYoG5AQL+sA/8DTLnRwsj3awXpIAsaGVSJjoZ78bWtN7+
RCaClH3yxNk2O87AJOaEsnBn4xDXtA7211vSPJI9i1QsfmADRsSFZpqDTMYTh1dX
e9K325H3MAFhFAFhXaXtJJ2zGgC85Kx1Gv+Oy2PAW8lxBgr3xAtzXCOi1o0wmgQW
SOY5JJZ50WrXIdM3Fm/YDDa5hlehvB9Qv+PgXlX/CniFEP2cPIujkwTBwwwX9HnD
sPalarhfooNAKyHbMiDV+z193+CtKzLQvdm8KFF+w6HyNqO+Bi2bcmjg4iSG/VW4
h6wWQcLeu6ZpPOgpQmluYLSbZTzws7Br7prrxMANET5zujAMCUkHMfRhhwRlPY4X
jo9LzOAwV4t4Bzz37Rwt0XY3zKqaLQ9tPSOAZGP3JxYZ+S/oNC7L/fBS3anN2aYG
0NNDHhfTQkfwUa05eJXn8m0q4L1dpm4EKVcgJsvay2rnCWSCV04XOYhOHwCmlHos
V+xC55y4SbkuDdbGd2uq+TiWc0HHho3LYZrgEmNZ8Mwt1mOQlJsTTvkocO7cJZPn
TpEpWqzYymtRvxTPGWlK5OENAYFbFdf9oZKgy69byAITw3PM37kZEIgeGRgvcYjD
DLDggQ4hmi4x9d9nvxyAJMTiIRtazMDwA8WavC8+ZBNzJ3daXROLJDH+HBcsbNdu
pqF52+ZnPQw=
=Q16W
-----END PGP SIGNATURE-----

--Sig_/DFr9hq6WTRAcvXWuECJr5rG--

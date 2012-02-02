Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54229 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755369Ab2BBE6R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 23:58:17 -0500
Date: Thu, 2 Feb 2012 15:58:03 +1100
From: NeilBrown <neilb@suse.de>
To: "Vlasov, Vladimir" <vvlasov@mera.ru>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Re-init lockd and kstatd in runtime.
Message-ID: <20120202155803.15d0bb42@notabene.brown>
In-Reply-To: <06EFEBD57610DE4FBCA0449DDF4E102B088BD0@tecas.te.mera.ru>
References: <06EFEBD57610DE4FBCA0449DDF4E102B08765D@tecas.te.mera.ru>
	<20120126224042.63cdd70e@notabene.brown>
	<06EFEBD57610DE4FBCA0449DDF4E102B0878A3@tecas.te.mera.ru>
	<06EFEBD57610DE4FBCA0449DDF4E102B088BD0@tecas.te.mera.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ysJ2_BTEJ30QD5s=G.ZZNpq"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ysJ2_BTEJ30QD5s=G.ZZNpq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 2 Feb 2012 04:50:06 +0000 "Vlasov, Vladimir" <vvlasov@mera.ru> wrot=
e:

> Well, nobody deal with HA Linux clusters?

I certainly don't.

And like I said before - you are a SUSE customer and you are using a SUSE
product so your best best it to ask SUSE for help.

The in-kernel 'statd' which you are fighting with is a SUSE-specific
innovation (which I thankfully got rid of in later products) so no-one here
is going to be likely to help you with it.

NeilBrown


>=20
> Best regards
> Vladimir Vlasov
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel=
.org] On Behalf Of Vlasov, Vladimir
> Sent: Friday, January 27, 2012 12:32 PM
> To: NeilBrown
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: Re-init lockd and kstatd in runtime.
>=20
> Finally I have found notes on HA NFS on SLES9 - http://www.gatsby.ucl.ac.=
uk/~johnp/compute/ha-nfs-sles9.html
> There are more info on this topic, for instance http://linux-ha.org/DRBD/=
NFS Suddenly I realized that previous designer was following these guidelin=
es :-)
>=20
> I have found that all documents suggest to have both primary and standby =
hosts configured as NFS server only and start/stop server processes when ro=
le is changed.
> This way /var/lib/nfs, even relocating on DRBD partition, is always avail=
able on NFS server startup.
> So, it is OK to have /var/lib/nfs as link to the folder on DRBD partition.
>=20
> What I have different is that my system breaks rule of acting as NFS serv=
ers only: standby host acts as NFS client until it becomes primary, then it=
 should act as server.
>=20
>=20
> I'll summarize info here:
> "server" is DNS record, resolved into IP of the primary host.
>=20
> HOST1, primary:
> /dev/drbd is mounted as /storage
> /storage is exported
> server:/storage is mounted as /some/path /var/lib/nfs is link to the /som=
e/path/var/lib/nfs and is available
>=20
> HOST2:
> /dev/drbd is not mounted, /storage is empty server:/storage is mounted as=
 /some/path /var/lib/nfs is link to the /some/path/var/lib/nfs and is empty
>=20
> So, due to this /some/path mount existing on both hosts I have problem wi=
th initialization of the kstatd on the standby host, where /var/lib/nfs loo=
ks like empty folder.
> I have requirement for having /some/path on both hosts, so I can't fallba=
ck to guidelines advices.
> I need to do NFS client became NFS server somehow. There should be some r=
untime re-initialization. This is what I'm looking for.
>=20
> Could someone comment on this?
> Is there any way to do so?
> Or any better solution?
>=20
> By the way, browsing sources I have found that one can set nsm_use_kstatd=
 to 1 on lockd exit, then initialization will be successful on next mount o=
r export attempts.
> I think someone can find it useful so created patch. Unfortunately I don'=
t have neither time nor enough code knowledge.
> In my case this proposal has drawback - lockd exits when all mounts are u=
nmounted only, so I have to umount /some/path first and then mount it back.
> It can be painful as soon as some files can be opened by local user and u=
mount will complain with it's usual "device is busy".
>=20
> Also I was thinking about having /var/lin/nfs locally, separate for each =
host, so kstatd will be initialized always, but how do I share vital info a=
bout clients then?
> I have found it to be dead-end.
>=20
>=20
> Best regards
> Vladimir Vlasov
>=20
> -----Original Message-----
> From: Vlasov, Vladimir
> Sent: Thursday, January 26, 2012 4:14 PM
> To: 'NeilBrown'
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: Re-init lockd and kstatd in runtime.
>=20
> Yes, it is SLES10 SP3 and I'm a customer.
> I'm not sure that Novell can help me, I expect the same proposal from the=
m - "just make sure that /var/lib/nfs is available on startup".
> I'm not satisfied with this because I have some kind of high availability=
 system built with two Linux hosts.
>=20
> Hosts share DRBD partition and one acting as primary exports, for instanc=
e /some/path.
> As soon as primary host fails, another one becomes primary and exports /s=
ome/path.
> There are more hosts on the network, they mount:
> server:/some/path
> where "server" is resolved to the IP of current primary host which curren=
tly exports path.
>=20
> So, in order to keep and overtake data about clients, /var/lib/nfs is rep=
laced with link and points to /some/path/var/lib/nfs.
> If You don't familiar with DRBD then the most important thing You should =
know is that it is available for R/W on primary host only.
> So, on primary host DRBD is R/W, /var/lib/nfs is available and kstatd sta=
rts.
> On another host DRBD is NOT R/W, /var/lib/nfs is empry and kstatd doesn't=
 start.
> This is why I'm looking for how do I re-init it at any time.
>=20
> I was looking for guidelines of using NFS in clusters but didn't found an=
ything useful.
>=20
> Best regards
> Vladimir Vlasov
>=20
> -----Original Message-----
> From: NeilBrown [mailto:neilb@suse.de]
> Sent: Thursday, January 26, 2012 3:41 PM
> To: Vlasov, Vladimir
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Re-init lockd and kstatd in runtime.
>=20
> On Thu, 26 Jan 2012 11:15:02 +0000 "Vlasov, Vladimir" <vvlasov@mera.ru> w=
rote:
>=20
> > Hi.
> >=20
> > I'm wondering if there is any way to re-init lockd and kstatd after sta=
rtup?
> >=20
> > Look, in svc.c static variable nsm_use_kstatd is set to 1.
> > Then, if nsm_kernel_statd_init() returns error, nsm_use_kstatd is set t=
o 0.
> > And we end up without kstatd.
> >=20
> > Lockd will exit as soon as last NFS mount is unmounted and on next moun=
t attempt lockd() in svc.c will be called again, but nsm_use_kstatd is 0 al=
ready and kstatd init will be skipped.
> >=20
> > So, looks like if /var/lib/nfs/state is missed on host startup, there i=
s no way to recover and tell kernel init kstatd later on demand. Or?
>=20
> This would be SLES10 - correct?
>=20
> I suggest you simply make sure /var/lib/nfs/state is not missing at start=
up.
>=20
> The issue sounds vaguely familiar ... maybe it is fixed in SLES10-SP4...
>=20
> What release are you running?  Are you a SLES customer?  If you are, you =
would be better off logging a support request on the SUSE bugzilla (bugzill=
a.novell.com).
>=20
> NeilBrown
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in t=
he body of a message to majordomo@vger.kernel.org More majordomo info at  h=
ttp://vger.kernel.org/majordomo-info.html


--Sig_/ysJ2_BTEJ30QD5s=G.ZZNpq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTyoX2znsnt1WYoG5AQJvfhAAmqX5rGEwacyZYYI69rR3m69IpK3JxDGT
kmvYZSmpA28geDtaesPZJAwOG81yOrWIfJdMAIhvgfYTDml5O/T1rLWR0eAVUA7v
M0FobxUd0vH11+z62TuJmffgIeWT0qGEWGyxFsJZ4Cpt17jQuyFZ+F5qCcxuE9ky
OHeKc/S4iJDoCgJk5DhlFQgwSIOvrzmt6QwhGwBJmM1PCKC7bWu9zHahiOCIsMuv
9DjM8925NuzKZkuCharqze2ns7q4NkTHsW67g04Gr1HNbUH16G3DunhVRrcSjGgr
yF2pwoqQJy1qOeZjrxwjJepdEziTLMuXGP/rOjbHvxjXv5hZq5RtpzvmVvXvlS/5
jg7XFU1amSLX/UxCaNKfFet4noE60aeMZXdiVVbSMprSaIyy8iR4kvmlG7eOkgXM
loVIuMRz4xg1pfQMXbar2hmNwmFbIwtLwWKrlDDD7gwo4xt8eT9luoyCbYszMGXO
Bvwy7UA/PL+73F1oQ+65oK9vxujR+b56+Nwihl6Z3j+zJBjS/wiP44rfuLQV0ORD
9B+vJ9wOf0wkAlrtUwYH7mJ/KWjI+ERwe1yQ0NTK+n2AtR08haaSdAyLUMtafQdl
NwNys7SFhach9ea9i5Xe3MdE7A19PalLCNWsL99gfkyawxyKJ+b6pgymogKA7fnm
NaYJAlRtSbI=
=tTGM
-----END PGP SIGNATURE-----

--Sig_/ysJ2_BTEJ30QD5s=G.ZZNpq--

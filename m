Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36990 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825AbbAKTyO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Jan 2015 14:54:14 -0500
Date: Mon, 12 Jan 2015 08:51:44 +1300
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: A couple systemd questions
Message-ID: <20150112085144.6460dc27@notabene.brown>
In-Reply-To: <54B295B7.9070509@RedHat.com>
References: <54B295B7.9070509@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ykFviL0VME3Emu8swAcHYvB"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ykFviL0VME3Emu8swAcHYvB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 11 Jan 2015 10:24:39 -0500 Steve Dickson <SteveD@redhat.com> wrote:

> Hey Neil,
>=20
> You being the architect of the systemd scribes ;-)  I have a=20
> couple questions.=20
>=20
> The nfs-server service brings both the rpc.mountd and rpc.idmapd=20
> daemons up when the service is started, but only=20
> brings rpc.mountd down when the service is stopped.=20
>=20
> I'm assuming that was done because the client was=20
> using  rpc.idmapd to do its id mapping, but that is no=20
> longer the case with some clients. They use the=20
> key rings via nfsidmap command to do the id mapping

Your assumption is correct.
Having nfs-client only require nfs-idmap on some configs is not easy to do
with systemd... at least I don't know an easy way.
We probably need to distribute two versions of some config file(s), one whe=
re
the dependency exists, one where it doesn't.

How does one tell whether idmapd is needed or not?


>=20
> So I'm thinking the nfs-server service should bring=20
> both daemons up and down when the server is started=20
> and stopped since the server is the only service using=20
> the rpc.idmapd.
>=20
> My attempted at doing this is to change the=20
> nfs-idmap service to do the following:
>=20
> [Unit]
> Description=3DNFSv4 ID-name mapping service
> Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> After=3Dvar-lib-nfs-rpc_pipefs.mount
> After=3Dnetwork.target
> PartOf=3Dnfs-server.service
> PartOf=3Dnfs-utils.service
>=20
> Wants=3Dnfs-config.service
> After=3Dnfs-config.service
>=20
> [Service]
> EnvironmentFile=3D-/run/sysconfig/nfs-utils
> Type=3Dforking
> ExecStart=3D/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
>=20
> Almost exactly what the  rpc-mountd service does.=20
>=20
> Now I thought the "PartOf=3Dnfs-server.service" would cause
> rpc.idmapd to come down when the server came down, but that=20
> does not seem to be the case... The only way I can get=20
> nfs-idmap service to come down is to explicitly stop it...=20
> What am I missing?

You are missing the same thing that I am missing.
I wonder if systemd gets confused by multiple PartOf directives.

The man page says:

  When systemd stops or restarts the units listed here, the action
  is propagated to this unit.

So if systemd is told to stop nfs-server.service, it should also stop
nfs-idmap.service...
Maybe try with only one PartOf?  Or with
  PartOf=3Dnfs-server.service nfs-utils.service


>=20
> Secondly, in all of the services where rpcbind is needed you=20
> reference the rpcbind.target instead of the rpcbind.service.=20
> Why is that?

Because rpcbind.target is a public name (even mentioned in doco).  I had th=
is
idea that when systemd unit files from one package need to interact with
those from another package, they should be careful to only use "public"
interfaces in case one package changes.
And I thought "rpcbind.target" was like a public interface.

I no longer think that.  The ".target" concept doesn't seem to be nearly as
useful as I thought it would be.

I would not object to changing nfs-utils to use "rpcbind.service" if that
would help anyone at all.

>=20
> The reason I'm ask is,  I'm seeing a problem  where rpc.statd fails=20
> to start because nfs_svc_create() fails. Meaning it was unable to
> either create UPD/TCP sockets or the registrations to rpcbind fails.
>=20
> I'm thinking its the later due a race between rpcbind and statd=20
> starting. I've seen races like before in with systemd services...=20

but but but, the whole point of before/after is to avoid races...

>=20
> So I'm thinking that race would not exist if the rpc-statd service
> would use rpcbind.service in the "Requires=3D" and "After=3D"=20
> statements instead of rpcbind.target. Right??=20

Don't know.  Try it and see.  If it works, use it.

Thanks,
NeilBrown

>=20
> tia,
>=20
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/ykFviL0VME3Emu8swAcHYvB
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVLLUZznsnt1WYoG5AQIyvw/6A1oB3PXUXwMtHvVCeh0bczCK7lq/xc19
uqAHN8XuuI7GqUJx4ankacH/Hy/BVN9RzrrSYvqMQAozwZXTCYJRRNvWvHdWht/i
IQDifEwqjlAeOKoRc12gKmk4Eower8BzOwYoxFLdSQL37w9neYpvnj10Zd+OELJS
6BSPBH7DhxqZepEUkJYOgNHBGwi7wcX+5agNN9vnZpYh7XvFPPUGYVP8m5OquEvH
WcsbR8xBOticRULrLyORYY7Equd6QpG3XCR/kCxQ0ypj7RRwtzygsm/1/mrLM6lx
jSEaatJduZJXhpF9xqQmTIts0/0SNogBNyPfErGG76mJ893fo0Y+qAiJ4rRgWOWs
cPcbGZr1dgNrUDje1bcj3NOjgq25fU8dqnkOBCvgsRVOGVEMDdQ064zjJQRkEcRr
sH0gfHmafhOujPvWyQEZa+/4WGgYC90KGCPFZOtU7P1H+mPjZOxJvkAnZQwN1Lfp
0jhqagDmOVXUdnTIUUOukK0GXuBHfq21+Gw6KgIZjOlm0KkSbKuL0T/nhWhNxyQj
Q69u1TSSWttY68vxRrFOom4vjMsOqWjdcv5piVNE9TP2Agpc0zFAurU7B1kpa3Xh
G4dRsJtR827Q2oZCxRi1EmkToLksPa5aIMiA6DArVJx4BzXVc1e/6qcL/xQ/Qlzo
51Hoj096YH8=
=pUss
-----END PGP SIGNATURE-----

--Sig_/ykFviL0VME3Emu8swAcHYvB--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54649 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020AbbBKXSV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 18:18:21 -0500
Date: Thu, 12 Feb 2015 10:18:12 +1100
From: NeilBrown <neilb@suse.de>
To: Nix <nix@esperi.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150212101812.10967f11@notabene.brown>
In-Reply-To: <87y4o4ujwh.fsf@spindle.srvr.nix>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87y4o4ujwh.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/z48nX/YyQbkSpERXgmJeZm1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/z48nX/YyQbkSpERXgmJeZm1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


> > It might be interesting to see output from
> >
> > 	rpc.debug -m rpc -s cache
> > 	cat /proc/net/rpc/nfsd.export/content
> > 	cat /proc/net/rpc/nfsd.fh/content
> >
> > especially after the problem manifests.
>=20
> It's manifested right now, as a matter of fact.
>=20
> # cat /proc/net/rpc/nfsd.export/content
> #path domain(flags)
> /usr/src        mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subt=
ree_check,fsid=3D16,uuid=3D333950aa:8e3f440a:bc94d0cc:4adae198,sec=3D1)
> /usr/share/texlive      mutilate.wkstn.nix(rw,no_root_squash,async,wdelay=
,fsid=3D7,uuid=3D5cccc224:a92440ee:b4450447:3898c2ec,sec=3D1)

You didn't run the "rpcdebug" command first (there is no '.').
That causes the 'content' files to contain extra information which might be
useful.

NeilBrown

--Sig_/z48nX/YyQbkSpERXgmJeZm1
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVNvjNDnsnt1WYoG5AQI58xAAgk8wutFHmlZ7uZry2iQT+VRXy9dld8IW
vH35PHmDVPerPIGFHZoUS9YHmjVl6ydmFLRhL43y3nNUgRa7+WGno8wPR4f17xZu
l7If3dBuCMXvUwJTTnnPOTQya+/miFOJV4pA2Jn86lEPobVSCtFWwwkjCnQcOp/h
K072KRk63ZpeByxIsdCWNQ2c5+B06utaRqhIrT5WeWAWucH7qa6UZGMn+wMQEgyT
ZVPL0SlilPAwRCxNMcmSAfn+KRVt+zPTvFl2WvDDqZ4MDm35DvpmyO7uoCasdznD
aOgFfh2jTlXcaMMHb6Q7Co4OweTNVrP8TH1YL/BUnMOaUKLzQtDXeekxZI0nFSi/
WXfA/Fjy/hyabwVwq4kkBTb7tmVJydpC58gUoHxwRSkH2CEOhHFccZ/exafVVJIe
dUXfeQUvAIIZgyryblcQTwMLb2Ue94eX2iIFDPBq4SbSWkWpcg9XTTnuYt1bnL1Z
32OK2SQKRZphm3vPIEIEuXR7QTUTQo4xX9FFWNdNn4caMdhgNlreAn6OdPINj/eb
q6chLuuO6M+BEWGluQAYjejM7/KV5v6vZgkI/yL8esZHQ4u/G2B5JlcqVyDW9M9C
EFdwgEWoWD8dPR7gOnFAFfUnVrUvReM5OVGR/LTBM9PjG1tJ1TY0v99iQkG8G+rH
Vc3T+n115JE=
=YOZI
-----END PGP SIGNATURE-----

--Sig_/z48nX/YyQbkSpERXgmJeZm1--

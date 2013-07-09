Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36869 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab3GIKBU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 06:01:20 -0400
Date: Tue, 9 Jul 2013 20:01:04 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - RFC]  new "nosharetransport" option for NFS mounts.
Message-ID: <20130709200104.086cb289@notabene.brown>
In-Reply-To: <20130709132253.3dd4f90a@notabene.brown>
References: <20130708095812.355d7cfc@notabene.brown>
	<1373309499.2231.46.camel@leira.trondhjem.org>
	<20130709132253.3dd4f90a@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nDnTwKH7M=wxY8tpGwyVpMM"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nDnTwKH7M=wxY8tpGwyVpMM
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 9 Jul 2013 13:22:53 +1000 NeilBrown <neilb@suse.de> wrote:


> A customer upgraded from SLES10 (2.6.16 based) to SLES11 (3.0 based) and =
saw
> a slowdown on some large DB jobs of between 1.5 and 2 times (i.e. total t=
ime
> 150% to 200% of what is was before).
> After some analysis they created multiple virtual IPs on the server and
> mounted the several filesystem each from different IPs and got the
> performance back (they see this as a work-around rather than a genuine
> solution).
> Numbers are like "500MB/s on a single connection, 850MB/sec peaking to
> 1000MB/sec on multiple connections".
>=20
> If I can get something more concrete I'll let you know.

Slightly more concrete:

 4 mounts from the one server, 10 threads of fio on each mount.
All over a 10G Ethernet.

1 IP address without "nosharetransport":  ~700MB/s
4 IP addresses without "nosharetransport": ~1100MB/s
1 IP address with "nosharetransport": ~1100MB/s

This is all NFSv3.  NFSv4 is much slower with nosharecache (32MB/s!), but I
might have botched the backport to 3.0 (or didn't address the v4 specific
issues you raised).  I haven't looked into that yet.


NeilBrown

--Sig_/nDnTwKH7M=wxY8tpGwyVpMM
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdvfYTnsnt1WYoG5AQIaEQ/8DrNE/EzYCVllYIGlkkYpW+KDSZcOa4QS
zyU/2NyLlV0cb7HXKb3hc877jymF+WlsIuI7Da2FquwOIW1z6suARzBFNo8y6gXA
7wnaTzBLfKeLr7Hq6Vn7jBY6LfKl0SnbvFUy7yr8wtC07kFuCiBXMBs99AikF2VD
l+zVWh+/40imH7lPh89RbePRvQJO6Eoo49EU9c5XTzMrscgKtWzXvnS+gso0XuXV
Eru/DESLRtHfathLKgoVfajN7imMyeKlGskAkWUTZ7iwid0PbRWzOB6NGtk7WQd9
/3da3GlwofPzuQvthd2ENSpkiite9bAyup5f2KZdNnXChWBJRO4NjVgzngYcaGOb
B8bVauR4MINGHrkqauw6N53tVWc3Vt30VMvM7yiwnNO2TB09hn/kQxFpQaM/H/9N
UjXVRwiHCuJ5GJF7X/yPCd5YzYdqTfJnU63voR8YyHcrcpASmvViCdQZzkj6jjio
I2cy8sXkKNmXZpCy2DTUfht+8il8L1j/iQxiONWLlPv5jSlK8sO8Dg2VfJtW0G6C
3GaprGFhDLtitDmgg87D1s6//+avFmcD31Jo8HDumUg6xvB8+p6mOvqHYbS9Dlcy
l+pwVrPthC8iRwLyP2o61c8SaNIxGpaPcr/8WxYTcAHzPVeALOkVYMMttUfEso8+
PTXGFiD9A40=
=SeoG
-----END PGP SIGNATURE-----

--Sig_/nDnTwKH7M=wxY8tpGwyVpMM--

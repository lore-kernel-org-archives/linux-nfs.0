Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48663 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754875Ab3FLGMw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 02:12:52 -0400
Date: Wed, 12 Jun 2013 16:12:40 +1000
From: NeilBrown <neilb@suse.de>
To: NeilBrown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130612161240.59b219b7@notabene.brown>
In-Reply-To: <20130606094336.4faf099d@notabene.brown>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
	<20130603122319.47f4e0dd@notabene.brown>
	<0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
	<20130603130101.4acfe706@notabene.brown>
	<C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com>
	<20130604093025.5e467eeb@notabene.brown>
	<9F47F7D4-9D96-424E-BAD9-21AE1C06A877@oracle.com>
	<2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com>
	<20130605112635.188f628e@notabene.brown>
	<1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com>
	<20130606094336.4faf099d@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/lvva/LID3E960hfdpk6It/U"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/lvva/LID3E960hfdpk6It/U
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 6 Jun 2013 09:43:36 +1000 NeilBrown <neilb@suse.de> wrote:

> I've provided a patched kernel to customer.  Hopefully will hear back soo=
n.

Hi Chuck,
 the patch appears to work exactly as advertised and completely resolves the
 issue - thanks.

Getting back to the idea of making this sort of thing work seamlessly,
another possibility to consider is to use the *real* uid  of the process
which performs the mount do authenticate SETCLIENTID - either as the primary
authentication or as a fall-back.
Then the a mountpoint with "users" listed as an option in /etc/fstab can be
mounted by anyone with appropriate credentials and no credential should be
needed for root, and not machine credential should be needed either.

NeilBrown

--Sig_/lvva/LID3E960hfdpk6It/U
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUbgRWDnsnt1WYoG5AQKuWg/+JCNt2CjdGrvts9maK0372ux2wjq5/XwS
eMEkOlDtNoP1DrEaWdXmHO6B6az78mjwh1zy9o+re1xdhJVgKnfCcyGSqNAF6y7B
ciqUpuYmG/ENpgNTBzCBp3oBm4cSDrrYMlcpRMXZjhoAJo09zSvxzVcxK/Er6wj0
WM3p7MOgTaAQWLG0ujOjAqaMqsQSzNcggR2Cy+dWSj+/h8+ghAH8Fsn5UuwksbfN
roq5crs7cH7gyZCFn9UbOrY21IBEpG/ycdLuGiOYXcyWNjBdNXWoEkjSKE6vQUuH
7ZkAPBCWunntJmcZWtbHIZA7/eEcUKh0mfY3BJ6K7kLe9siot8qseI8TFQFiVrEB
+uYlcY/L3EFFSd3qOfD4hhTVJwE/1TWs7yVOYh3OGyvsWNS4f0PsBl/rzmGea+5U
gp+6xGLLvVmbW30LWdAFECLvQdW4TtKc/x6tgZy5/QJB2l7Oe3ckxMPVg3WoZxrb
uKkLszyUkWWEQeqxkM4aEb4VMKxJBcnVomkeaflTUpKVk4GG/JQHkNbl/e+Hv07b
27kmRQPDuzQypB+drOFZr+604dTLsVUHdxPIjsT8dePbbGuN7Vx90V2uk/S/qWIo
/jog3tNpKpruTAfUzYgiYiX7chHL8GXz+AEmeTp2fVslf7X+vYX0/ry06pXi2ytE
Z/GSPrTw0uc=
=bB2R
-----END PGP SIGNATURE-----

--Sig_/lvva/LID3E960hfdpk6It/U--

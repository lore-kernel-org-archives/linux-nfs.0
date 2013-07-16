Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37734 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755419Ab3GPBLG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 21:11:06 -0400
Date: Tue, 16 Jul 2013 11:10:55 +1000
From: NeilBrown <neilb@suse.de>
To: Jim Rees <rees@umich.edu>
Cc: "J.Bruce Fields" <bfields@citi.umich.edu>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130716111055.566352aa@notabene.brown>
In-Reply-To: <20130715134211.GA14237@umich.edu>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<20130715134211.GA14237@umich.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/1V3/WbYw=2yjZZRAz0HW=4H"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/1V3/WbYw=2yjZZRAz0HW=4H
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 15 Jul 2013 09:42:11 -0400 Jim Rees <rees@umich.edu> wrote:

> Here's the thread on netdev where we discussed this issue:
> http://marc.info/?l=3Dlinux-netdev&m=3D121545498313619&w=3D2
>=20
> Here is where I asked about an api to set a socket buf minimum:
> http://marc.info/?l=3Dlinux-netdev&m=3D121554794432038&w=3D2
>=20
> There are many subtleties, and I suggest anyone who wants to try to fix t=
his
> code should read the email thread. The netdev people were pretty insistent
> that we turn on autotuning; David Miller said the old behavior was
> equivalent to "turn[ing] off half of the TCP stack."

Thanks for those pointers.
Certainly autotuning is what we want.
The issues with the receive buffer getting tuned too low appear to have been
addressed some time ago.
The issues with the send buffer getting tuned too low are not what I at fir=
st
thought they were, but still are not completely resolved.
My previous patch which allowed N requests beyond the available space is, I
now think, more than necessary.  You just need to make sure one can get
though.  That should be enough to push the sndbuf size up quite quickly.

I'll revise it, test, and repost.

Thanks,
NeilBrown

--Sig_/1V3/WbYw=2yjZZRAz0HW=4H
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUeSdnznsnt1WYoG5AQL+ERAAwEMpQ8eTpsHxAfzEDPzgxd9WKkwB1qUs
dkvN0mHJMBwjKKuIlWT1Hl5CDD1nXDAJ/Q5Qh1B8dcja0WSjvTG12bptp56XpZIk
WCWorPxuQNJrbOhg8KBhoZrPL4q3FS7N56vhxvuhuzDfhMQa34FS6QYHHeCoBPGR
6v9E4+GzpBD/9wwAX0X8MPmQqTPPT5xZ6If+VhJuCZYMMp3v6ocrzf4PdIcmNNqG
lVy7W8W77d9FKTC2xQoBem4w/Q45a9nkcV5yY4xsdS7i29cqOpWTa95n0s3uTniT
6ykPiiJdNWnzUIg9pT9+1uHbOKEeeD/xrDznVFuZcjkvxqJzLMbPjfpbwQQGe4nC
PNAE1aVoePDnoSN5nZOBS7t5Zxe1k4fOKIRffjJyR2PPc+T1w0U5Gg8kR6xApEwg
J3RfaF6766QohL35aoEo7XgnE8XTI76ncr8FFTIbT/Xskd8wu3aeRwEP2Cp2Qkaf
L7U3aSC6IIj5egzZWL/8vtYDM5U9a2E6UtumoQCJkewmqErHi5Xu4EOlo8kJSa2X
H0fYiDO63g5gDrKmxK1ySPVWClVAjVqETuPCqbNsgy0TLWZRAy4l9N8JCmf3uP1M
5j4VEzWevUWceExw73sWE7Ot0RTdgTWA1zsEYE2L7lsLChebTNWog01JmXc1ivyb
NvyWTBGznUo=
=T/gP
-----END PGP SIGNATURE-----

--Sig_/1V3/WbYw=2yjZZRAz0HW=4H--

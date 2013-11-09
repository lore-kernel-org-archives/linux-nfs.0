Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43157 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757309Ab3KICE6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 21:04:58 -0500
Date: Sat, 9 Nov 2013 13:04:44 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131109130444.2e0e9f73@notabene.brown>
In-Reply-To: <20131108101232.10d49851@tlielax.poochiereds.net>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
	<A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
	<527C07B4.800@RedHat.com>
	<44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
	<527CDBFC.3070903@RedHat.com>
	<20131108082202.4032f1a2@tlielax.poochiereds.net>
	<527CFC72.2030907@RedHat.com>
	<20131108101232.10d49851@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/+0mPYZQqf/X1WKg+1698u5t"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/+0mPYZQqf/X1WKg+1698u5t
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 8 Nov 2013 10:12:32 -0500 Jeff Layton <jlayton@redhat.com> wrote:


> Right, but we've defaulted to v4 for *years* now. Most people run statd
> and don't actually use it. No one seems to get bent out of shape about
> that though.

Given that statd can be started on demand by mount.nfs, this sounds like a
configuration error.


NeilBrown


--Sig_/+0mPYZQqf/X1WKg+1698u5t
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUn2YPDnsnt1WYoG5AQIn0g/+LrEjfcvQ2/ycOLh7qE9pDvZhJhRUl+RZ
k5BPctYzL2A4ZptoSvZf6+qDAROu7Hulcz5kIBWb/av7lsAeuZNsxgXa9o+sLzAq
XKl6Mo+OUD2DlftsmQ1LSZJSu4ozyTj0nUle/Q3gRjYApJdD2ZeO0DDR5fL3PvcF
RmlCXsmzzgwVZto98XYnBAnmDwR0xJql7RUa6t3uqN12m+aER8BfVttm/VG2ts7B
0P1+nMc+QrWT1Hbe/T09orV3BDeenFSDrP++WwGz6DN4lI5LY8ZoJ7Fj7uxgHN/g
1ecUk4LQuqT3ZXoJdi6/Tmv2N5Zlbyw4kxLQsA0aWigM2EH7aIfuiodYm4tcGKK4
qrCiKg1SUpAwaK1EpYyrLZFBCWeROPMh6ATp77ibwmUdcvr1ljWH5np2aMXSExmk
y221O3D8VYU53q9jEXcF3UdqEnCWSwghaBgi1zvFBS71pzaggQGp2RglpXGnCWLK
75kpg0nqtiQVznNyU9HQq3F3RUiJNB+aQ6ZojYg0FprSdfz0fJSU0WBgO8uOXWa/
VwCDYOXUsgeT0sxs9TSI9vRVNKho7auY8QeXVuDvkxYqTGwVOuSontF+NcLSgS2+
q4LeRKNwtTiFq8D9Cd3RNo2E7qTfb1FOzlfbOE+5/cu4gfMop226RFA3yicvqfp4
VkqZAp3wHiU=
=r0/C
-----END PGP SIGNATURE-----

--Sig_/+0mPYZQqf/X1WKg+1698u5t--

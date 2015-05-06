Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177AbbEFI0g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 04:26:36 -0400
Date: Wed, 6 May 2015 09:26:30 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: drop stale setup_socket doc comments
Message-ID: <20150506082630.GA24280@stefanha-thinkpad.redhat.com>
References: <1430835480-29982-1-git-send-email-stefanha@redhat.com>
 <5548F98F.5050601@Netapp.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
In-Reply-To: <5548F98F.5050601@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 05, 2015 at 01:10:39PM -0400, Anna Schumaker wrote:
> On 05/05/2015 10:18 AM, Stefan Hajnoczi wrote:
> > xs_local_setup_socket() and xs_tcp_setup_socket() have outdated
> > arguments listed in the doc comments.  Drop arguments that no longer
> > exist.
>=20
> Can you please fix up xs_local_data_ready(), xs_udp_data_ready(), and xs_=
tcp_data_ready() while you're at it?

Sure, will send a v2.

Stefan

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVSdA2AAoJEJykq7OBq3PIUIwH/izXN+fCoO2ZTsNoGG5Sa2nb
hg4OwR5jM7FZt963DvtE7gHKDgGp+VLA3gA2mXK6vxzszypkramZrX807DZhUWSf
8tu2MgdSUgDne/BPp/Jc7VVUUJ7EvNRQ0KCTOonoz36F5xoTCm/lf3AoVl+3BQyq
u8OXZFp4S6NsRStRChlB/vsw15gzdEQCwchhkt4k2cBhvfm5ZwpKWEElUQXOj8dH
r9mEUgVMOgxEcc70yWxwqc4vfE3tmmnCUxzC8XylRdct+GxUDtcdvzkJvhwQuhlp
zhB7oJRusnOtX8Dze5kQ2UVi1JFdm26jLQDPF+/L6+ZV5oTnhvOIu5HnrQuR5SU=
=KLR+
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--

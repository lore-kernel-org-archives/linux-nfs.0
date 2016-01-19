Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932271AbcASVBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jan 2016 16:01:14 -0500
Subject: Re: [PATCH v5 11/10] svc_rdma: use local_dma_lkey
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
 <20160108075341.GA24754@infradead.org> <20160108140204.GA27867@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
From: Doug Ledford <dledford@redhat.com>
Message-ID: <569EA417.7060803@redhat.com>
Date: Tue, 19 Jan 2016 16:01:11 -0500
MIME-Version: 1.0
In-Reply-To: <20160108140204.GA27867@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="aHGgVN5ixoCplskJQmIPlRGNxUQA89D4K"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aHGgVN5ixoCplskJQmIPlRGNxUQA89D4K
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01/08/2016 09:02 AM, J. Bruce Fields wrote:
> On Thu, Jan 07, 2016 at 11:53:41PM -0800, Christoph Hellwig wrote:
>> We now alwasy have a per-PD local_dma_lkey available.  Make use of tha=
t
>> fact in svc_rdma and stop registering our own MR.
>=20
> Acked-by: J. Bruce Fields <bfields@redhat.com>
>=20
> --b.

Per off-list communication with Bruce, this series has been applied to
my tree.  Thanks.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--aHGgVN5ixoCplskJQmIPlRGNxUQA89D4K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWnqQXAAoJELgmozMOVy/dEykP/0D9Wi882VhDZGb1vGgaKID4
sY+20wQlh3kk2UbhTtzUyFzD+Yx2+hd4ro67slVWJhBakNu3lnHUi8u159jzI1gw
wKtvL26Tk28u8UjgMantB+BR3P4zIGuXZkjNNxeKp3+EYOJos3uaaqc+ATj01hGw
tyLWz5tUoJjszvJ5A78/8YsNvoxthde/osox4+rtHiMSV7KhouQC6s4fEXkw2MKB
NDB5Blk/Eec9A/gqMIkTfk/dhqzwNWsdtIGajlcBEPAvXubtKNUfVG4J9DNu0xN7
Tc7wafu/HrtfVZHVdYQJ0/Y/i51YDFyVu44l2G082qhacMCB3B3Zw0Hpu/4KuvF0
FIWDzgp7fRvUHBlVpiy5vtbPQi0Op0eEfUq00YJpUxcvB5PL0UFWd0FR00JlqEPR
wriHkCYOS327ePc1ZFBtwKDzB344BHNgugUqrrCGbdYU0tussFuFP/HVvz4wGK9Y
rQE6e8k+ympDcpMojLgPfcp1OhvyjimDKnuCjVyDX3ZAkwPUV8PTFviXSey21+i/
QUEnwd2ckAIWPd+IM1RWw6cr+SHPRzFmi7OdwhuaoSN2Ok9O7n7j/It72gLYyWd3
2nQSSpyLrM3vkEQ2Dyv1NUCPPTot19iqDrYs0H1ev7FSFQrR0RL8xtYzxddgmJmY
GcRy49pJT80QBy3tKngU
=bG5H
-----END PGP SIGNATURE-----

--aHGgVN5ixoCplskJQmIPlRGNxUQA89D4K--

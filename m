Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbbFKJTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jun 2015 05:19:14 -0400
Date: Thu, 11 Jun 2015 10:19:11 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 00/10] NFS: add AF_VSOCK support to NFS client
Message-ID: <20150611091911.GF840@stefanha-thinkpad.redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
 <20150608210247.GB27887@fieldses.org>
 <20150610164315.GD17294@stefanha-thinkpad.redhat.com>
 <20150610180926.GC8922@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DEueqSqTbz/jWVG1"
In-Reply-To: <20150610180926.GC8922@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--DEueqSqTbz/jWVG1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 10, 2015 at 02:09:26PM -0400, J. Bruce Fields wrote:
> On Wed, Jun 10, 2015 at 05:43:15PM +0100, Stefan Hajnoczi wrote:
> > These are all at the SUNRPC level rather than at the NFS protocol level.
> >=20
> > Any idea who I need to talk to?
>=20
> Anyay, if there is anything to be worked out, nfsv4@ietf.org is the
> place to go.

Thanks, I can write a summary and send it there.

Stefan

--DEueqSqTbz/jWVG1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVeVKPAAoJEJykq7OBq3PICE0IAJislVKV9soHP2uUcWodqPjz
9pNVuKRcKMlaWHEPXMEXOgLbglIEJzjlDE2wmhPBAjhFJkwTZwJ+g8ZB8bQzawpN
UXfU8nrzGYEYEMlwIuF61G0GYmiFMMMpsQLXJlkfdeWmLW18MjW76c1zUvhiY1UA
91LvGgIP7Ayck5cLKoGxCU/UrvO6AbBLqMsG7HAzsJUCdkBpfk2cmFhnx8+9qguW
jHMHMeihxMNuBTz7pcqGaNwMdYmgpKRnZnGYZhxOFuXU7dV0g16GpL/eTFeuxXbw
z24uoGPJtsnE17vyHUOSkDSdzuOHf9xjBd3QDsn+flMLTycGKk/PI5DxdjPU0GI=
=Kh0f
-----END PGP SIGNATURE-----

--DEueqSqTbz/jWVG1--

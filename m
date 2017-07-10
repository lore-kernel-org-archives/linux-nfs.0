Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754748AbdGJSOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 14:14:50 -0400
Date: Mon, 10 Jul 2017 19:14:47 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Felix Janda <felix.janda@posteo.de>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
Message-ID: <20170710181447.GW14195@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
 <20170703090048.GC22607@stefanha-x1.localdomain>
 <2730896d-f9d6-352d-e829-d672d8735bd3@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="/Y6L//1es8ezVqBy"
In-Reply-To: <2730896d-f9d6-352d-e829-d672d8735bd3@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--/Y6L//1es8ezVqBy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 03, 2017 at 12:51:07PM -0400, Steve Dickson wrote:
> On 07/03/2017 05:00 AM, Stefan Hajnoczi wrote:
> > On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
> >> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> Are there other implementations out there that would cause breakage?
> I'm pretty sure nfs-utils is only used in Linux environments, right?

Does nfs-utils have a set of minimum distro versions that are supported?

For example, "the latest nfs-utils release is supported on RHEL 6, SLES
11, and Debian 8 jessie".

If yes, then I could go check that these distros ship AF_VSOCK and
<linux/vm_sockets.h>.

Stefan

--/Y6L//1es8ezVqBy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZY8QXAAoJEJykq7OBq3PIkiMH/iqY5HfSH3iY0SROv38xR0e9
FphHe8z86d94euFkS8z9cDxAQzDrTleiTtD/uCnRC4iWvmZKojcRynpKpkDbQpEt
v10HZ4D3D9ckfcEWV5GV5rsbCx0rgFK+0WAJ93FbjhL5NdTVYKTwEZ5SfjPFVbJC
YQS+bnMoZkuqoX9LHvhwbbRweoZdsyJL9Ew+jQO6iOFmO1scQJ2uEgopIPba9ECs
MnmypiJCRaKjwbeK8F7NTqRBm6F5JjNdAcirQPGl7t+Uk/VbJtluUVZjSDdHNWJW
YlRc6Y55ntBTeIXY03njG/pK5l/X+nqdpx7Jk/HmhWAH0PPwEdDpd9VcyuZhttI=
=4VfN
-----END PGP SIGNATURE-----

--/Y6L//1es8ezVqBy--

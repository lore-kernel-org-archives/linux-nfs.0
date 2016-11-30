Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756091AbcK3KVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Nov 2016 05:21:14 -0500
Date: Wed, 30 Nov 2016 10:21:05 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 00/10] NFS: add AF_VSOCK support to NFS client
Message-ID: <20161130102105.GB17934@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
 <CALXu0UdS_m6ag7VDdbc-aJWH+fK=42GM0FEWH1Ht9M-9xy9Xjw@mail.gmail.com>
 <20161020143603.GC2733@stefanha-x1.localdomain>
 <CALXu0UeW6Cssiij_+VW8afnHre3zwvBcg5OR=J7A2WKUv9fRWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
In-Reply-To: <CALXu0UeW6Cssiij_+VW8afnHre3zwvBcg5OR=J7A2WKUv9fRWA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 27, 2016 at 03:05:35AM +0200, Cedric Blancher wrote:
> On 20 October 2016 at 16:36, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> > On Sat, Oct 08, 2016 at 02:42:17AM +0200, Cedric Blancher wrote:
> >> So basically you're creating a new (Red Hat) Linux-only wormhole which
> >> bypasses all network security between VM host and guest and needs
> >> extra work&thought&tool support (wireshark, valgrind, ...) to handle,
> >> trace, debug, monitor and secure?
> >
> > vsock is not Linux-only and not Red Hat-only.
>=20
> This is clearly Red Hat only. Debian and Ubuntu folks already have
> rejected this out of security concerns, so why are you pressing this?

Are you aware that Debian ships the vsock.ko and
vmw_vsock_vmci_transport.ko kernel modules?
https://packages.debian.org/jessie/amd64/linux-image-3.16.0-4-amd64/filelist

Do you have a URL regarding virtio-vsock in Debian and Ubuntu?  There
was no discussion upstream in QEMU or Linux that I can recall.

Stefan

--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYPqgRAAoJEJykq7OBq3PI05YIAIawUHylE9bH6KZ0iZG3kp2N
MhWQaG0FQlPIdAHcOFoAMbPn+/bHd4r2AtcMbiTCJZ7Zq3+9o3XiFBYr/WcB65A5
fbk+tFPU32O6a8zt6nh361/IL8CGLaLmg7KhzgMpHKJIthyHaxWAJC5639lHeEtj
6NfEDKlI56E8J5eU/hA5efgFcpPfeWkYAXELZZNLQMun4GLvISoSHeaAMJOt1Iqz
fFYqudRlKTU3n5xSYqNx62SYlZUPq7TLT4CijrmdOQN2l0RaFhgfFccIgEBpgvao
P5JNpmOkqAqopZZ2A5iygbZl9OKbqEjgypR9wX2YjcFKl2YfHSk0n9yiEmqbC/U=
=H8aZ
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--

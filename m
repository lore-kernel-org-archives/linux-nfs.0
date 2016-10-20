Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34918 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933337AbcJTOgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 10:36:05 -0400
Date: Thu, 20 Oct 2016 15:36:03 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 00/10] NFS: add AF_VSOCK support to NFS client
Message-ID: <20161020143603.GC2733@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
 <CALXu0UdS_m6ag7VDdbc-aJWH+fK=42GM0FEWH1Ht9M-9xy9Xjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Fig2xvG2VGoz8o/s"
In-Reply-To: <CALXu0UdS_m6ag7VDdbc-aJWH+fK=42GM0FEWH1Ht9M-9xy9Xjw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Fig2xvG2VGoz8o/s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Oct 08, 2016 at 02:42:17AM +0200, Cedric Blancher wrote:
> So basically you're creating a new (Red Hat) Linux-only wormhole which
> bypasses all network security between VM host and guest and needs
> extra work&thought&tool support (wireshark, valgrind, ...) to handle,
> trace, debug, monitor and secure?

vsock is not Linux-only and not Red Hat-only.  There are two
paravirtualized hardware interfaces (VMware VMCI and KVM's
virtio-vsock).  Drivers for other operating systems exist and can be
written for OSes that are not yet supported.  The virtio-vsock spec is
public.

Regarding bypassing network security, this is a non-routable
guest<->host protocol.  It is very locked down by design.

You can simply not use the device if you prefer to go inside the guest
and configure a traditional NFS TCP/IP setup instead.  As mentioned in
the cover letter, that is not feasible for cloud providers and other
scenarios where reaching inside the guest isn't allowed.

--Fig2xvG2VGoz8o/s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYCNZTAAoJEJykq7OBq3PI9QEH/2bZAwiWU79GHO0ay6n0ywDZ
Tws41ROwcXGe2om10alTJu1GFYz0APG5sT8BKHpj0n29AqXGbJ2s8JLanpmqWxlq
88fG1LMjGQadiBryxtEDnfckqw5ORnDdWwQzm13vR+l1qHI8urQFB7J/VmB9n8vy
5GVoXdWrMwFfYhLbBDsHxARD9D+e1plQg7sjWi6MfT5IFxDZ5/B+Tc5nlEY6fo5W
l+oBo/E4EdNhlmXELCSzeqhtuPz3Wbiwu5WM8Y2W2kR/yjNXj0ZQe9s8rOxM11os
rBHC4PB1IQh5zmBflwpEQEgAcbnI6nnwXodyutvvY5pZqhGUYd2H8A1Sy3J1YKg=
=72lt
-----END PGP SIGNATURE-----

--Fig2xvG2VGoz8o/s--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753185AbdKXK7a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Nov 2017 05:59:30 -0500
Date: Fri, 24 Nov 2017 10:59:28 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: nfsv4@ietf.org
Cc: linux-nfs@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
Subject: Remote Procedure Call (RPC) over AF_VSOCK draft 00
Message-ID: <20171124105928.GA11868@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The first draft of Remote Procedure Call (RPC) over AF_VSOCK is now
available for review:

  https://datatracker.ietf.org/doc/draft-stefanha-nfsv4-rpc-over-vsock/

I have tried to incorporate feedback from the discussions we had on
the linux-nfs mailing list.

Jorgen: I've summarized the current AF_VSOCK standardization status
(i.e. there is no specification and implementors generally try to follow
VMCI semantics for compatibility).  VMware vSockets is a superset of
Linux AF_VSOCK because it has additional header files and APIs.  Is
there an authoritative reference for plain AF_VSOCK that I'm not aware
of?

Dexuan: I know you're busy but just keeping you in the loop in case
there is any interest from the Hyper-V side.

Thanks,
Stefan

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaF/uQAAoJEJykq7OBq3PIsIQH/0WPgqKVnzM2u2Nfd/jPgNCD
I0i/gm4x9OqvgR1qvEolvb1y4fo2B4AMm0LPnRvEs703y101NkNJJPf5hrQh92DO
UR2wx8sl/fNC14Zd9FEjE/OwonfblMFlkpBXNNQWeQC6uRDzYcq6ty8V2vE+AOmL
vDXnyRk5djczkRYO4nvYsSg43KMlexojKPhXGpsWmXfV3Zlmh7bc/nMKl2KAtL+Q
mbEb/FHBtav14ukqD9pXd79cUbOBsNrB2Dd5DyW7pi5fOl3b+envyaYFzzb8cZH6
FEiM/P5LYHVc8Xu0YRJ2oi5rPEsqzNEJII6aUyu3P1b6DECN5AdVrUo4pSizRvc=
=wY2M
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--

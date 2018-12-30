Return-Path: <SRS0=b1dW=PH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6E28C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 30 Dec 2018 01:49:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 71EB420866
	for <linux-nfs@archiver.kernel.org>; Sun, 30 Dec 2018 01:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="GedR9QYj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725872AbeL3BtG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 29 Dec 2018 20:49:06 -0500
Received: from ozlabs.org ([203.11.71.1]:59909 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725866AbeL3BtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 29 Dec 2018 20:49:05 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 43S3JZ5L1Sz9s0n;
        Sun, 30 Dec 2018 12:49:02 +1100 (AEDT)
Authentication-Results: ozlabs.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1546134543;
        bh=KED+RCP53qxX644/baeXgIPDlQAb+n5QaqFvy1Am8kc=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=GedR9QYjDXAVV0YNKiC47aGkqXPAdkVP0E8Vj4Ai9gGkLmhPIfNNPgjhTtFs9yjDc
         s/BnJV+gfFJlBCtS73MO4P6jjFFaJOAcBuR/05DE6U0Lti7RTEZXHSpsQc2GrqpuFa
         hYLo9vFKhHcGU3Aw+QEzvidcRuK1uGsAVoeTMA369HXWf1MwqiXQG7Vgo6BYex0nkX
         8mSGP0u0vl+NTODqdSv5pvO6WGf5JsT26l6yF4I+JbQ2fVp/4BAzWtj7pwiEhizxrA
         5HkUKYP4Zam3s75dyvePDdWJb9OEgtlw8KSAydfYJL6Assq6dYzWk0k9pTG4XgTJhm
         I5ek9cX1TrP3w==
Date:   Sun, 30 Dec 2018 12:48:47 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Doug Ledford <dledford@redhat.com>,
        Jason Gunthorpe <jgg@mellanox.com>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Kamal Heib <kamalheib1@gmail.com>
Subject: Re: linux-next: manual merge of the rdma tree with the nfs-anna
 tree
Message-ID: <20181230124847.09855735@canb.auug.org.au>
In-Reply-To: <20181224141352.461303be@canb.auug.org.au>
References: <20181224141352.461303be@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/fQ9swKvDDvNOmfMtlkvAh+5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/fQ9swKvDDvNOmfMtlkvAh+5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 24 Dec 2018 14:13:52 +1100 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Today's linux-next merge of the rdma tree got a conflict in:
>=20
>   net/sunrpc/xprtrdma/fmr_ops.c
>=20
> between commit:
>=20
>   d31f8deac38d ("xprtrdma: Remove support for FMR memory registration")
>=20
> from the nfs-anna tree and commit:
>=20
>   3023a1e93656 ("RDMA: Start use ib_device_ops")
>=20
> from the rdma tree.
>=20
> I fixed it up (the former removed the file, so I did that) and can
> carry the fix as necessary. This is now fixed as far as linux-next is
> concerned, but any non trivial conflicts should be mentioned to your
> upstream maintainer when your tree is submitted for merging.  You may
> also want to consider cooperating with the maintainer of the conflicting
> tree to minimise any particularly complex conflicts.

This is now a conflict between the nfs-anna tree and Linus' tree.
--=20
Cheers,
Stephen Rothwell

--Sig_/fQ9swKvDDvNOmfMtlkvAh+5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlwoI/8ACgkQAVBC80lX
0Gx8zQf+PzBOOkT2I/QlmiFm9z3e6K7yj8ceByWoFSm2Vk7ETUqyErykrrI3ZiRR
XUlbmBiZXSgJomzSvYDH6Yw7nsr21cdr/Hmv87b9A4JK6CRmyzmCNO3p2/cZm2at
S4V54mQotkVBlnXZroEiWEhZa9XZdJubVx0Mfq/2oDieD7CDqF4YqZeQC4q2V7Gw
KeEOhqbzPVs191wX3/md7TOZjZ+Raeqhnz0PFZYoLF8wo9UH6LjNUu2e2mWqj06A
G7NnWydZGJtWNB+GVOMfzKnmJmr3SagST6bNJgpLHRCx/7ilsdf8y9H7Y5oytOzU
EWI8wFYnS0LAsFzdBS7zit6Q07AMiQ==
=D89L
-----END PGP SIGNATURE-----

--Sig_/fQ9swKvDDvNOmfMtlkvAh+5--

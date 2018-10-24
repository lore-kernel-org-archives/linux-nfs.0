Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 881C7C004D3
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 11:26:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2AB90207DD
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 11:26:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AB90207DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=intellique.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727302AbeJXTyM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 15:54:12 -0400
Received: from mail1.g1.pair.com ([66.39.3.162]:52114 "EHLO mail1.g1.pair.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727000AbeJXTyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Oct 2018 15:54:12 -0400
X-Greylist: delayed 566 seconds by postgrey-1.27 at vger.kernel.org; Wed, 24 Oct 2018 15:54:11 EDT
Received: from mail1.g1.pair.com (localhost [127.0.0.1])
        by mail1.g1.pair.com (Postfix) with ESMTP id 827A7547694;
        Wed, 24 Oct 2018 07:17:03 -0400 (EDT)
Received: from harpe.intellique.com (labo.djinux.com [82.225.196.72])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail1.g1.pair.com (Postfix) with ESMTPSA id 2961D60B0C7;
        Wed, 24 Oct 2018 07:17:03 -0400 (EDT)
Date:   Wed, 24 Oct 2018 13:16:53 +0200
From:   Emmanuel Florac <eflorac@intellique.com>
To:     "Benjamin Coddington" <bcodding@redhat.com>
Cc:     "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: Archive the list at lore.kernel.org
Message-ID: <20181024131636.655d6d51@harpe.intellique.com>
In-Reply-To: <BFE6266E-D3D5-4EDE-9409-B33A61D0E8AE@redhat.com>
References: <400E82D9-5BA9-4542-988A-B2C598F72693@redhat.com>
        <BFE6266E-D3D5-4EDE-9409-B33A61D0E8AE@redhat.com>
Organization: Intellique
X-Mailer: Claws Mail 3.17.1 (GTK+ 2.24.31; i586-slackware-linux-gnu)
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/F_TQyJwEycmzkNYRI3MEMyx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/F_TQyJwEycmzkNYRI3MEMyx
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Le Tue, 23 Oct 2018 10:58:28 -0400
"Benjamin Coddington" <bcodding@redhat.com> =C3=A9crivait:

> Anyone want to help?  Just bumping this during the work week.
> I'll wait until Friday.. then send what I have.
>=20

That's a noble endeavour, unfortunately a few months ago I scripted a
strict purge of my mailing lists folders. The only one I forgot to
auto-vacuum is linux-bcache, for which I have everything up to may 2015.
For all other lists, I don't keep anything older than 3 months anymore.

--=20
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------

--Sig_/F_TQyJwEycmzkNYRI3MEMyx
Content-Type: application/pgp-signature
Content-Description: Signature digitale OpenPGP

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlvQVLEACgkQX3jQXNUicVbCXwCg7hQgRARRrWywT80PUY6Mj9O8
t2UAn2LFHTmSCz4MrtfbRVYw7hwI0hLV
=Hxo0
-----END PGP SIGNATURE-----

--Sig_/F_TQyJwEycmzkNYRI3MEMyx--

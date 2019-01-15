Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C70BC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 21:38:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E668214AE
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 21:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="WsIEge4v"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733092AbfAOVie (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 16:38:34 -0500
Received: from ozlabs.org ([203.11.71.1]:35857 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1733071AbfAOVie (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Jan 2019 16:38:34 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 43fNxg5cdTz9sDT;
        Wed, 16 Jan 2019 08:38:31 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1547588312;
        bh=FotrQ+eIvHhrVLNz8zPgyfOmWZ4vZQgFqZprdR3kfGg=;
        h=Date:From:To:Cc:Subject:From;
        b=WsIEge4v4mq281InoxLSzcP+aEqUls4cwyDIv1Oif2SR3V92B8gnOKXv/53l55OJY
         9d8BKdW6sQIsQYxfGIkcQdSb/sk+pATpdmGRIZaetCh73iiIulwR92eXa5Jr+gnBZo
         w8ubwZvK1un5TanA1zaKlJDuI3G/SNLXyqtME3eIX2RTRRQBpYNoiMgxwpG3G07wLv
         O/adbZkge2yiyh8oxXaawQSPNqS3asIebfKJDEaWDa5CmjCQVEc09MFT+CfRbKg7bQ
         Hd0aJ8QvXO8wehmhazX7VxBrMFtAB5hwYCjBFL7e0aSujcUlK4GgbdOWEp3oj9aJYM
         EQ3NlBa5+epuw==
Date:   Wed, 16 Jan 2019 08:38:31 +1100
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: linux-next: Fixes tag needs some work in the nfs-anna tree
Message-ID: <20190116083831.256824cf@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/1h5dzV+7Tjewx0X38wEgIld"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/1h5dzV+7Tjewx0X38wEgIld
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

[I am experimenting with checking the Fixes tags in commits in linux-next.
Please let me know if you think I am being too strict.]

Hi all,

Commit

  deaa5c96c2f7 ("SUNRPC: Address Kerberos performance/behavior regression")

has problem with this Fixes tag:

  Fixes: 918f3c1fe83c ("SUNRPC: Improve latency for interactive ... ")

The subject should match the subject of the fixed commit.

--=20
Cheers,
Stephen Rothwell

--Sig_/1h5dzV+7Tjewx0X38wEgIld
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlw+UtcACgkQAVBC80lX
0GwZXggAmPnNzm6PKW98wUJiTP8uO8hDUoiKhdWOboko6FhJ2zDgs33TBvC2A1kV
2KymX1+/ngBJL4uzMJE/hmtV3YdyQ/7AEhglL9g4Oa/RLvx7s34TGq3tk6p9w1X+
o2QmYndmjvTAr5BuvB9M+5/bxFoKIoA4AHLUAy6Jc0zgp8UOIy1mfFDrszvkTxpl
omyXwc0qgrE+/rCx5q2HdIkhIBFaBUibwnrlamSMZwz1jmFm+QpqyHi95xNwayct
cELMWxJlRR5BPLtyFhYwjV/D0UFxbx6hi94aN30R0CD0pVqYrMmXoXzAGFUMyY0h
9qdkRd/GWAUWzPXbQibO8QjEcuDtSA==
=+UWx
-----END PGP SIGNATURE-----

--Sig_/1h5dzV+7Tjewx0X38wEgIld--

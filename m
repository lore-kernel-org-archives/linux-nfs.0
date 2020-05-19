Return-Path: <SRS0=FnX5=7B=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEAA4C433E1
	for <linux-nfs@archiver.kernel.org>; Tue, 19 May 2020 18:30:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AEBCF207C4
	for <linux-nfs@archiver.kernel.org>; Tue, 19 May 2020 18:30:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="QEpthBRF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726747AbgESSag (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 May 2020 14:30:36 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38020 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726161AbgESSag (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2020 14:30:36 -0400
Received: from ozlabs.org (bilbo.ozlabs.org [IPv6:2401:3900:2:1::2])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5A954C08C5C0;
        Tue, 19 May 2020 11:30:36 -0700 (PDT)
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
        (No client certificate requested)
        by mail.ozlabs.org (Postfix) with ESMTPSA id 49RPZf5VLHz9sRK;
        Wed, 20 May 2020 04:30:34 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
        s=201702; t=1589913034;
        bh=SFuRTS9+gsJOEt25G5xbN66octtTZc5pVmdnC8JSOYY=;
        h=Date:From:To:Cc:Subject:From;
        b=QEpthBRFmd43iIY8p0vuV5Mp3WB2/0eKTluuZ/LZTP8xRONH579DjzRhcHk6SV1oS
         XO/4z+N+KYk6urcgUBwfjSnx9j1pKYz4WfR/g4AJlXkfyalVHwmmVjEkF546FUtu5X
         UGAtG7hBJH4w/AJ1KuKmOEuWHZCLAKR9y4WCqD6nhcfr9EqZ6Ml3S/8fV8LOfzpaKd
         71uEIDujTkcFnYkAmOBVSZSpofByN78wqMs603Ro98A0/uxu5bosOVN+P1+YvLpQHF
         5l4LmKinHsU/FgTsyg/aGaXSPyD3diNmck9anKsdGqr9zuY1HuJMUQtKvj21tf5lex
         YmBgOX291z/dg==
Date:   Wed, 20 May 2020 04:30:33 +1000
From:   Stephen Rothwell <sfr@canb.auug.org.au>
To:     Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>
Subject: linux-next: Fixes tag needs some work in the nfs-anna tree
Message-ID: <20200520043033.036c78ac@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/wf5Y6selKu=mRUD6OJSU6pF";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--Sig_/wf5Y6selKu=mRUD6OJSU6pF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

In commit

  049a9d8a9117 ("NFSv4.1 fix rpc_call_done assignment for BIND_CONN_TO_SESS=
ION")

Fixes tag

  Fixes: 02a95dee8 ("NFS add callback_ops to nfs4_proc_bind_conn_to_session=
_callback")

has these problem(s):

  - SHA1 should be at least 12 digits long
    Can be fixed by setting core.abbrev to 12 (or more) or (for git v2.11
    or later) just making sure it is not set (or set to "auto").

--=20
Cheers,
Stephen Rothwell

--Sig_/wf5Y6selKu=mRUD6OJSU6pF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl7EJckACgkQAVBC80lX
0Gw40AgAgKe6CQ2f2H1eOxpBpI+V2ulc+2ivYjOW8s5WxndVEN3VN+F+o836/JO6
TS/WUmcnwXf6pAFULbMCmhOBWPTpIdKIHWgmOKBZiVIaZvtBN0mt2Sq02avbXecN
itK7/uhvE2Oz8uEmT1eAlkw8Olu+i22PvrXWY9unv0pqaTkEWCd0EceLTWk2sKRx
5xULqXHpO/5S1VS7E4Ne7Y3hHkZ6rOeeHzD1nqn0gYH/GYDL0HnZZZ1RWqEfM2WT
qEqeG2g8MzTTvah4RFP00g1/TJ+k8DZO4ok6O3We/Phrf00bIEnuuNxvBj+n8J5v
/+p9w78wgOzXVdAF4/lxUOtlCsXkYA==
=heuu
-----END PGP SIGNATURE-----

--Sig_/wf5Y6selKu=mRUD6OJSU6pF--

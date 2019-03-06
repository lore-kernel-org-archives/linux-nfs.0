Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 995F6C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 19:46:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 610C720684
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 19:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=poochiereds-net.20150623.gappssmtp.com header.i=@poochiereds-net.20150623.gappssmtp.com header.b="uM09ScpR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729378AbfCFTqy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 14:46:54 -0500
Received: from mail-yw1-f41.google.com ([209.85.161.41]:34966 "EHLO
        mail-yw1-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726143AbfCFTqy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2019 14:46:54 -0500
Received: by mail-yw1-f41.google.com with SMTP id s204so11066581ywg.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Mar 2019 11:46:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=poochiereds-net.20150623.gappssmtp.com; s=20150623;
        h=message-id:subject:from:to:date:user-agent:mime-version;
        bh=4bf0STDUPlw9YIZhsfolod6vOusWosg1rYH5jfnYcxs=;
        b=uM09ScpRdq389pzs553iRC4i0yAEKXNEiqECVc3lPL1dKvFQfCGG+7Z2ol1CxGe+NA
         KL2XOInty7Bws/Iw0onw3UxdQe6FgimC4xW4sl90wJHtpD8cljzrZ+u71AMMj3jjVSmn
         BzLNDwAXG+bMulUMyl6UWU5Zn8EZonysvtft74y0AD4C6bgwMLW0Jt2+s34sTdXNQYy5
         5C/ROwQi+KBQMHPxgCf4mIzfs7buvq6CJQMzuqkXbT1INPnVV9xZvJuxOsIARHozql+W
         o54kheAw21E3SplOiiDvGC9TnT11G/kOh/uhEDp2dSme8f0zy9NwWz5dk6WIdzkSOqFc
         AItQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:date:user-agent
         :mime-version;
        bh=4bf0STDUPlw9YIZhsfolod6vOusWosg1rYH5jfnYcxs=;
        b=GU5+P0EqiIQQIoHmN4zSNSJn392pIq6RSlGzjgH48rBv5MiZANcuTnyC9ia8KV+33+
         bNH8DcCGJuuZjJDCwPlTY3ojrCzqBeM7U8ck7RHMFNkX/sR92wqcgrPjZ25YK9J1OXqG
         cf9yxsPLVQ8nUo+tHpWs7alVkoy68vUujZ5TckHA4XR8HPMkFtxUpyWOf1JtHkQa8ixN
         udTa/GzXSr2gMTcMeStPDou8F9lrxir8fX00unNK8V0YqDGwFESgKpCqqaBG5jYYs8Yv
         3wmtgLpCVmsTBujEFlyzhPPpONLLLMIDJ298tnEdege/3RVsRwGGly5c9Pi8Yo8leLHs
         2A7g==
X-Gm-Message-State: APjAAAWb5pVrYy6CPkcSE+9HyMabA9zAiH/vllFiCzPK0ks2iJOhN5gV
        3E1rkChdE+/kOHE1IfT34axUNA==
X-Google-Smtp-Source: APXvYqx8DF0gU/nNhYd4Vr9DKVSSBhVOvidGkj7jkEv7t31RgtcL+v1QNZR0n3iVNraoSYtBsQO4Uw==
X-Received: by 2002:a81:9bd6:: with SMTP id s205mr6847841ywg.354.1551901613040;
        Wed, 06 Mar 2019 11:46:53 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-6D3.dyn6.twc.com. [2606:a000:1100:db::6d3])
        by smtp.gmail.com with ESMTPSA id a194sm843718ywh.103.2019.03.06.11.46.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 06 Mar 2019 11:46:51 -0800 (PST)
Message-ID: <04463ae0a2005fee74867fd5c90745b980b43b01.camel@poochiereds.net>
Subject: Deploying a Ceph+NFS Server Cluster with Rook
From:   Jeff Layton <jlayton@poochiereds.net>
To:     ceph-devel <ceph-devel@vger.kernel.org>,
        "devel@lists.nfs-ganesha.org" <devel@lists.nfs-ganesha.org>,
        ceph-users <ceph-users@ceph.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date:   Wed, 06 Mar 2019 14:46:45 -0500
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-wf3twI7kA5nG6+svlJHR"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--=-wf3twI7kA5nG6+svlJHR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I had several people ask me to put together some instructions on how to
deploy a Ceph+NFS cluster from scratch, and the new functionality in
Ceph and rook.io make this quite easy.

I wrote a Ceph community blog post that walks the reader through the
process:

    https://ceph.com/community/deploying-a-cephnfs-server-cluster-with-rook=
/

I don't think that site has a way to post comments, but I'm happy to
answer questions about it via email.
--=20
Jeff Layton <jlayton@poochiereds.net>

--=-wf3twI7kA5nG6+svlJHR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEES8DXskRxsqGE6vXTAA5oQRlWghUFAlyAI6UACgkQAA5oQRlW
ghXpEBAAqbtEURfdDvdRiYT9tx4GhQ8vZ3n/9copksl3E+BRozjstzCgllnVwD32
KXW0TDM22XsrOE36A8V8WHUz25qjpnSi9c+y22zoJjfufY2/lO3tJ9L54th+YGZ6
wKiOwe3ieuAiCWPzfRLchsduLuSB+8sl+JBAtzk5tNLlujjk9LSyCdMVB2Qrn2dZ
h+LtKu5FrRU13HJHB3U17I2l3yEDjU8lQ0DdwxPVaXQDsZEnrwZf+i9k35wNRFWV
SSl/s+PRh8ZhBPu2xQWG/wRo+UH9to8q386TCdmOaWXxUZqVlUBdj0h+ciI4lhFw
KDQyDZecDFvoowMkBO3bb8u4PbsxkCo6H8ORZ4N4dOC4k9T4QlI5AW0o8PA+/s5a
g6/cTWKQmrD9oC54jO+/NDTZLRELb4ApBCX+UwNNi78ePNNksu8RZOfN6XAu9DaS
31U8nSjQXhSCJ8g9QR5K5fPyY2wvfKxMJ9QMz0inb9XyqCgbQiX4QoZjyvrJKLne
ez3HrTFuwTZtSz2GZE4uehNs46tAvFKSLJMU6lcPrdDlcTHK9V/qoQN0k6P7uk5o
XzLc+2RpFxSuIdG1XMgixR3v93nlGPziE1+JiyOAJd2kVAK80anqBkC7dz0YcdLR
O9KDeJVTmsKJvZGr1/s5/SbggBwqFDgpPjJY4dWQGr2TFy+eIYE=
=Mrtu
-----END PGP SIGNATURE-----

--=-wf3twI7kA5nG6+svlJHR--


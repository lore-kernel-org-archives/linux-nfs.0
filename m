Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADB1CC169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:36:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7921920811
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:36:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s4rd8bRl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730734AbfBFQgw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 11:36:52 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:53757 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730678AbfBFQgv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 11:36:51 -0500
Received: by mail-it1-f195.google.com with SMTP id g85so7600422ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2019 08:36:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=b5vQkZ5EwIghhyP45maUlonztQdANSAAjy/ZYXqEI1M=;
        b=s4rd8bRlddQusr5L0yA9BGqBUPei8bmQDAkOhlLYfCiJJTsKwaWoF8S8Psxn8pBI2M
         SASoNuubKpAL/lwv5fSNgnouGF5PSAVsPfkXlJmc2q9RbT8gtifQIQ4mk7H54LS8lcWV
         +CqlRyBLrtDrwdPtl46QFxEvWuzNNLaodLpZIkn/KZCKkiP0o2Yh6NMsBEGRmDriBMOj
         tFLCGFmwKLZB9Q59LUWFdeFxGqQQxUKdUYO83Ouwi5Ih8V79Wa4eOBS8aHfQe8/SjRoC
         mEUGsOwX+yPKBQUOctm0UNR1wF3YobfERHdZCTb1eyVdgU6yubouo7+2suM3Ka4R514p
         /Bmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=b5vQkZ5EwIghhyP45maUlonztQdANSAAjy/ZYXqEI1M=;
        b=SmIid2/BCnt4+TT+qZbcAKsxa3uQYsQCbQYhuMPE7gsgPWY4OZCakzP5AqmPLvGCK0
         X4u6g0dX482R3FyluD+CtFy89T0rKJ+za3wx/KBfz9K7dgiDwi7gY21DplddBaywyUUM
         JSPLF0js1UgdsIdAlkxMSX9pSTtK0uS1twyCZeSweu2XJmPs5yfaBOdzN8KuNvuFRDSK
         l6i/lvWxWjAZyI6+TpYb8S5sgmzyLTVvZfbwiBQibMcx0/jKYmYk3E2GnISEUmawOCfP
         /zMgjygrZ5DuqsAFvHbMzy17oz+XZMzNafPNCcKjNrQlVs5L7eljP9kpRy+kNEQ01PdS
         3Q9w==
X-Gm-Message-State: AHQUAuY6nhI27MfltG7wY9v3mk6D4kKLjvvhvlw06m2zuSOOmeopGE2A
        GX9KCdOgyjxjrB/s9EYmnQiaUvYM
X-Google-Smtp-Source: AHgI3IZsBaKHGlw+6IdVVE/6nFIrpaFDtmtXbXvoEyK86TkFn/Np6pILAkIez8grtMTBJ1lcdHieLA==
X-Received: by 2002:a6b:6e11:: with SMTP id d17mr5027624ioh.297.1549471010475;
        Wed, 06 Feb 2019 08:36:50 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x17sm975930iob.11.2019.02.06.08.36.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:36:49 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16Gam1k015984
        for <linux-nfs@vger.kernel.org>; Wed, 6 Feb 2019 16:36:48 GMT
Subject: [PATCH RFC 0/5] Reduce reply buffer requirements
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 11:36:48 -0500
Message-ID: <20190206163256.16810.62516.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi-

Last set I have for consideration for v5.1, please review and
comment.

My interest is in reducing the size of the RPC reply buffer, since
for RDMA, this is often registered memory. If I can get away with
one or two fewer chunks here and there, that helps improve transport
scalability.

These are a little incomplete and tasteless. I'm hoping someone can
help me give them a little more shape.

---

Chuck Lever (5):
      SUNRPC: Introduce rpc_prepare_reply_pages()
      NFS: Account for XDR pad of buf->pages
      SUNRPC: Make AUTH_SYS and AUTH_NULL set au_verfsize
      SUNRPC: Add rpc_auth::au_ralign field
      SUNRPC: Use au_rslack when computing reply buffer size


 fs/nfs/nfs2xdr.c               |   33 +++++---------------
 fs/nfs/nfs3xdr.c               |   39 +++++++-----------------
 fs/nfs/nfs4xdr.c               |   66 ++++++++++++++++++----------------------
 include/linux/sunrpc/auth.h    |   14 ++++----
 include/linux/sunrpc/clnt.h    |    3 ++
 include/trace/events/sunrpc.h  |   37 ++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |   19 ++++++++----
 net/sunrpc/auth_null.c         |    2 +
 net/sunrpc/auth_unix.c         |    6 +++-
 net/sunrpc/clnt.c              |   30 ++++++++++++++++--
 net/sunrpc/xdr.c               |   11 +++++++
 11 files changed, 155 insertions(+), 105 deletions(-)

--
Chuck Lever

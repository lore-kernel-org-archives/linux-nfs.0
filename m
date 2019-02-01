Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADCB0C282D8
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 799FF218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KG3bTOUM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728891AbfBAT5a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:57:30 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:51712 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727097AbfBAT5a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:57:30 -0500
Received: by mail-it1-f194.google.com with SMTP id w18so11108617ite.1
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:57:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=v2i9oR6PCLtQGa63IsbYcQt31SoUsMATbGhcVlCTPZ4=;
        b=KG3bTOUMvAwsnrJsvOaWDq9r1x3mMLF+JTwfRw0vTMnRcgy9g/uPaSO5GkrJPspn/S
         EyVT9bScCLX0+9BhIhsxSZR4VR8FARp5mLbgCB8UgcGuYvc85hOZ7wdRAYBN4DVeCPRB
         g1kSd/40kUictpra8sTcQ3mE1EOER0Ax+PrHmO7DeBbHUfnEzZOxf2KTvySRrezphKyJ
         U7lMmP6SXPlDYr94voAxsdwomWCOCTmDbAqU5Vx7B2DtVCYBOVGQS/4OAC6gEh9ULeG1
         TTgjvCyl7wCgKCH77/aIj+nbkl6sBw8721AsdlY4GjDsz556ZFAVKZrQ2akJtCQergv+
         Fmag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=v2i9oR6PCLtQGa63IsbYcQt31SoUsMATbGhcVlCTPZ4=;
        b=D988lw3CUyIPjJHwL9VhkagpNxqhNFSs3hGRCWC4hBhZlJmRhqmo078R+xgMgHThV5
         NAfaCGnIXh/hlW44MzBRZPKd2GaDfVJWr7vskg57EwtXMhXhH7HaE53vSOe4kr9iBidB
         Gg8jM051sr86LQRKrR4mf9rpYV8vxmbDrLr0aZlY0LVKnqJ7DZT10rGaxVd0ixes53U2
         dwbID7GadIgU+gZDMwxg0/7eCQk0ivv8oKhIeCav8z7xS3ZyW29X02iM5mMa11SjtkQE
         oHs7sisrPpiK/ORLT1YvfAmgKlTVmL+GsoKeVXAjR4h35E0ut675sSU+qzMxHiVrKRec
         LQoQ==
X-Gm-Message-State: AHQUAuYTB4ZVpCAq6Cf1YwNd2Gmp2uqG9bgC68ze8F8u8KDZZEr1dHPd
        zXOETESkx6c+4hN+PeBDJ7s=
X-Google-Smtp-Source: AHgI3IaqSmmFVuEkbFM1KILB+/djxjDOsCRU3TLfTxsIdFnm5BbodwyljU+U6cOvBBUnZBElwDOKCQ==
X-Received: by 2002:a24:7284:: with SMTP id x126mr2714893itc.96.1549051048967;
        Fri, 01 Feb 2019 11:57:28 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u126sm1664522ita.1.2019.02.01.11.57.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:57:28 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11JvQXm008693;
        Fri, 1 Feb 2019 19:57:26 GMT
Subject: [PATCH RFC 00/10] SUNRPC GSS overhaul
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:57:26 -0500
Message-ID: <20190201195538.11389.96106.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi-

Request For Comments on this series, which converts the rpc_auth
paths (including GSS) to use xdr_stream. It applies on top of the
series I sent last Friday.

I'd eventually like to see this work in v5.1.

---

Chuck Lever (10):
      SUNRPC: Remove some dprintk() call sites from auth functions
      SUNRPC: Remove rpc_xprt::tsh_size
      SUNRPC: Add build option to disable support for insecure enctypes
      SUNRPC: Add common byte-swapped RPC header constants
      SUNRPC: Use struct xdr_stream when constructing RPC Call header
      SUNRPC: Clean up rpc_verify_header()
      SUNRPC: Use struct xdr_stream when decoding RPC Reply header
      SUNRPC: Introduce trace points in rpc_auth_gss.ko
      SUNRPC: Remove xdr_buf_trim()
      SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/ files


 include/linux/sunrpc/auth.h                |   30 +-
 include/linux/sunrpc/auth_gss.h            |    5 
 include/linux/sunrpc/gss_krb5_enctypes.h   |   42 ++
 include/linux/sunrpc/xdr.h                 |   67 ++-
 include/linux/sunrpc/xprt.h                |    7 
 include/trace/events/rpcgss.h              |  361 +++++++++++++++++++
 include/trace/events/rpcrdma.h             |   12 +
 include/trace/events/sunrpc.h              |  142 +++++++
 net/sunrpc/Kconfig                         |   16 +
 net/sunrpc/auth.c                          |  136 ++++---
 net/sunrpc/auth_gss/Makefile               |    2 
 net/sunrpc/auth_gss/auth_gss.c             |  542 ++++++++++++++--------------
 net/sunrpc/auth_gss/gss_krb5_mech.c        |   29 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c        |    8 
 net/sunrpc/auth_gss/gss_mech_switch.c      |   27 -
 net/sunrpc/auth_gss/gss_rpc_upcall.c       |   15 -
 net/sunrpc/auth_gss/gss_rpc_upcall.h       |   16 -
 net/sunrpc/auth_gss/gss_rpc_xdr.c          |   15 -
 net/sunrpc/auth_gss/gss_rpc_xdr.h          |   17 -
 net/sunrpc/auth_gss/svcauth_gss.c          |    3 
 net/sunrpc/auth_gss/trace.c                |   11 +
 net/sunrpc/auth_null.c                     |   54 +--
 net/sunrpc/auth_unix.c                     |  112 +++---
 net/sunrpc/clnt.c                          |  360 +++++++++----------
 net/sunrpc/svc.c                           |   19 -
 net/sunrpc/xdr.c                           |   41 --
 net/sunrpc/xprt.c                          |   10 -
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |    1 
 net/sunrpc/xprtsock.c                      |   91 +++--
 30 files changed, 1326 insertions(+), 866 deletions(-)
 create mode 100644 include/trace/events/rpcgss.h
 create mode 100644 net/sunrpc/auth_gss/trace.c

--
Chuck Lever

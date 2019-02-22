Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 114BBC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:54:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6ED2206BB
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:54:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cWn/zfOR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726826AbfBVUyi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 15:54:38 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52714 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726056AbfBVUyh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 15:54:37 -0500
Received: by mail-it1-f196.google.com with SMTP id r11so4961880itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 12:54:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:user-agent:mime-version
         :content-transfer-encoding;
        bh=86IdcXWQ7UwpsKCWk/Rw5so6gPJ2u/1mL4Py+/4C8Rs=;
        b=cWn/zfORgdFJbFUDGtWJ3Jb2NjEP+Tc+z6Yj/uxupVJgXuFR+zF9SnClB20l15l12d
         hWiWAMiu0UxCpgn2p1MUbTcOy5WEx5OMpB1iJ85aR3BA+t6EL+2PWkolnUmZqOk1bzV6
         tWgXjJSeXBnGCZOPDhKp6R08SomY7/x2MwA9N7DGYIUGS7+K71vyks3BZx1XI2czUxBR
         arH9xAkIpnBAbh3Es7DWI0U+RxdjLKgjZAXUymB6/F/QDCGlufKpjoAfedSD1WcjH/RG
         s7gFN5R/+8i/1L/IIjeS8TKZXy8H8E2PJvEW+AObCmtAI9olVolW6AaS1Jrvvxoj8mAm
         YWMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :user-agent:mime-version:content-transfer-encoding;
        bh=86IdcXWQ7UwpsKCWk/Rw5so6gPJ2u/1mL4Py+/4C8Rs=;
        b=VJ/0IUxmX2x0+TkvTWkpSfvWH1jlLs2CCpPqHTlGyHUwsH7fr5BU2x0ipe3MjLd2y6
         PaJnj0QGdk/UqUOVDchYFg4NsxM7ak4gZ7cOwWXfEu6/F7qi1jr3eZlU2Vgp18FhiGeW
         v4RfFTHk5LayQdYT8oIyPJZT7pPgA3BNOukxHmGMgNgRhdSkNDF4ge2qE3FT4bbpNPJR
         2WMWW2Bg5nqPlldho0P3Ux6XinHayoPTs1dKhE4aOdh3dx+niIPutQJ4APTWQOvJVS5l
         8/8puwbx0vZ8CFhGZPnnOKIxX2jgtkoV/39Dc7WzYiIWvIqzjF3bPuAUDqR2flyq5CrG
         2C/g==
X-Gm-Message-State: AHQUAuaj917cJYHH5Uv/B+EeObHhVagK5W9bVT3Wo64MRWjw8ENYu1Go
        /TJRV6jGHaPvu/txQSGvfDZBhz8d+Ds=
X-Google-Smtp-Source: AHgI3IYVTm5dx1NBwFXg7OKU6oLoo7x6sghUkLK4XunL6Prh7sNWeWhPj4lhNyzzvAASRiiu7FrpAw==
X-Received: by 2002:a24:e502:: with SMTP id g2mr3322284iti.78.1550868876326;
        Fri, 22 Feb 2019 12:54:36 -0800 (PST)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.googlemail.com with ESMTPSA id n10sm1211089itb.39.2019.02.22.12.54.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Feb 2019 12:54:35 -0800 (PST)
Message-ID: <486306ab8bb34942b2719b8250950727f382f5ce.camel@gmail.com>
Subject: [GIT PULL] Please pull NFS client updates for 5.1
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date:   Fri, 22 Feb 2019 15:54:33 -0500
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

The following changes since commit d13937116f1e82bf508a6325111b322c30c85eb9:

  Linux 5.0-rc6 (2019-02-10 14:42:20 -0800)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-rdma-for-5.1-1

for you to fetch changes up to 2c94b8eca1a26cd46010d6e73a23da5f2e93a19d:

  SUNRPC: Use au_rslack when computing reply buffer size (2019-02-14 11:58:44
-0500)

----------------------------------------------------------------
New features:
- Convert rpc auth layer to use xdr_streams
- Config option to disable insecure enctypes
- Reduce size of RPC receive buffers

Bugfixes and cleanups:
- Fix sparse warnings
- Check inline size before providing a write chunk
- Reduce the receive doorbell rate
- Various tracepoint improvements
----------------------------------------------------------------

Chuck Lever (23):
      xprtrdma: Fix sparse warnings
      xprtrdma: Check inline size before providing a Write chunk
      xprtrdma: Reduce the doorbell rate (Receive)
      SUNRPC: Display symbolic flag names in RPC trace events
      SUNRPC: Add xdr_stream::rqst field
      SUNRPC: Add XDR overflow trace event
      SUNRPC: Add trace event that reports reply page vector alignment
      NFS: Remove print_overflow_msg()
      NFS: Add trace events to report non-zero NFS status codes
      SUNRPC: Remove some dprintk() call sites from auth functions
      SUNRPC: Remove rpc_xprt::tsh_size
      SUNRPC: Add build option to disable support for insecure enctypes
      SUNRPC: Use struct xdr_stream when constructing RPC Call header
      SUNRPC: Clean up rpc_verify_header()
      SUNRPC: Use struct xdr_stream when decoding RPC Reply header
      SUNRPC: Introduce trace points in rpc_auth_gss.ko
      SUNRPC: Remove xdr_buf_trim()
      SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/ files
      SUNRPC: Introduce rpc_prepare_reply_pages()
      NFS: Account for XDR pad of buf->pages
      SUNRPC: Make AUTH_SYS and AUTH_NULL set au_verfsize
      SUNRPC: Add rpc_auth::au_ralign field
      SUNRPC: Use au_rslack when computing reply buffer size

 fs/lockd/clnt4xdr.c                        |  14 -
 fs/lockd/clntxdr.c                         |  14 -
 fs/nfs/callback_xdr.c                      |  64 ++--
 fs/nfs/flexfilelayout/flexfilelayout.c     |   2 +-
 fs/nfs/nfs2xdr.c                           | 124 +++----
 fs/nfs/nfs3xdr.c                           | 209 ++++-------
 fs/nfs/nfs42xdr.c                          |  21 +-
 fs/nfs/nfs4trace.h                         |  25 ++
 fs/nfs/nfs4xdr.c                           | 529 ++++++++-------------------
 fs/nfs/nfstrace.c                          |   1 +
 fs/nfs/nfstrace.h                          |  85 +++++
 fs/nfsd/nfs4callback.c                     |  13 -
 include/linux/sunrpc/auth.h                |  44 ++-
 include/linux/sunrpc/clnt.h                |   3 +
 include/linux/sunrpc/gss_krb5_enctypes.h   |  42 ++-
 include/linux/sunrpc/xdr.h                 |  23 +-
 include/linux/sunrpc/xprt.h                |   7 -
 include/trace/events/rpcgss.h              | 361 +++++++++++++++++++
 include/trace/events/rpcrdma.h             |  12 +-
 include/trace/events/sunrpc.h              | 361 ++++++++++++++++++-
 net/sunrpc/Kconfig                         |  16 +
 net/sunrpc/auth.c                          | 136 +++----
 net/sunrpc/auth_gss/Makefile               |   2 +-
 net/sunrpc/auth_gss/auth_gss.c             | 551 ++++++++++++++---------------
 net/sunrpc/auth_gss/gss_krb5_mech.c        |  29 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c        |   8 +-
 net/sunrpc/auth_gss/gss_mech_switch.c      |  27 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c       |  15 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.h       |  16 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c          |  15 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h          |  17 +-
 net/sunrpc/auth_gss/svcauth_gss.c          |   3 +-
 net/sunrpc/auth_gss/trace.c                |  11 +
 net/sunrpc/auth_null.c                     |  56 +--
 net/sunrpc/auth_unix.c                     | 120 ++++---
 net/sunrpc/clnt.c                          | 390 ++++++++++----------
 net/sunrpc/svc.c                           |  19 +-
 net/sunrpc/xdr.c                           | 121 ++++---
 net/sunrpc/xprt.c                          |  10 +-
 net/sunrpc/xprtrdma/backchannel.c          |   2 +-
 net/sunrpc/xprtrdma/frwr_ops.c             |   4 +-
 net/sunrpc/xprtrdma/rpc_rdma.c             |  22 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   1 -
 net/sunrpc/xprtrdma/transport.c            |   1 -
 net/sunrpc/xprtrdma/verbs.c                |   2 +
 net/sunrpc/xprtrdma/xprt_rdma.h            |  12 +-
 net/sunrpc/xprtsock.c                      |  91 +++--
 47 files changed, 2071 insertions(+), 1580 deletions(-)
 create mode 100644 include/trace/events/rpcgss.h
 create mode 100644 net/sunrpc/auth_gss/trace.c


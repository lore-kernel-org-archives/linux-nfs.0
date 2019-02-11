Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B63DC282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3B177218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A0fDY8uj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728443AbfBKQXq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:23:46 -0500
Received: from mail-it1-f179.google.com ([209.85.166.179]:37180 "EHLO
        mail-it1-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726892AbfBKQXq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:23:46 -0500
Received: by mail-it1-f179.google.com with SMTP id b5so27653990iti.2;
        Mon, 11 Feb 2019 08:23:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=s6/ESaA/4T4OdWyawChuAmrykaMbforRmjjUJ7STm8o=;
        b=A0fDY8uj33OWgltpO6UO7ICckymhkACFT34dVhI4SRL3EeeI+xw9dzVzh+ueU/pP5/
         7Z/qpb3bQ8tPdaBamoCl1fC+P/uMtMYi1zhLIr25Gu+H7EECtEZkIEy3iFoFGMMuuQmb
         +RsYsiAeNN8pfSwCgt+5jW6jmFRoSprw3ya4v23bc3wA6gKbkFV7qu4nim4qR6oAfQTI
         weP1ERzSU6JF6JCW7sJhus9kfH0NrCahCZBgAGmZbGTdGORKC8EpMN22k36zekR9Ltp5
         Tcb853/Ve0b7zj6dAfAvSSTo+kl4id2/v2QXqPEpYWehFOGh3wMaAT1KS23MkHLi0CXg
         tODg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=s6/ESaA/4T4OdWyawChuAmrykaMbforRmjjUJ7STm8o=;
        b=czAuUrxt3aREO4tCHkh8JkGETDOeMsiMYweE9jI5WfpqAQzf4KocKaJ8PIGQHohWhs
         VT1GB55Qyies9WRnBsKgxqkKQyWYSj6EsX8NtmoEcScWOfEzQ3m7gk4bKmHnF22J8K7y
         7OrSBtdDZyUJqgAg775/wafFzeKy7n1jyQe4Ub03dCdxCNW7vJfjbhR/ayYJNXDIXqhu
         lP18cqEnKJkSPNrvh42M19iRyPUo1JYYC4FPmvuqtRJGoO09dzUda7sLa1gN+HJ6SMI0
         pxFx+LRN0EIzBfhSjuxMz3+e0k2uZBbbdPguay6K5q8jonkRMQguikr5A671Ksul5F2m
         Ss+w==
X-Gm-Message-State: AHQUAuYmn8PQGtKsq6+0plFf2vya4InU309zSPO6JXjRF4Y/dDbb0Vgr
        3yztXNpRmTXfAYzSG/7RHRk=
X-Google-Smtp-Source: AHgI3Ibxz4x/olCCHo+cUyNBI2th5fvYLefjDqEjCXtWkXwG269YPppL9h7W84kNEkIBWwMvW3tMPA==
X-Received: by 2002:a6b:d004:: with SMTP id x4mr3592808ioa.79.1549902220505;
        Mon, 11 Feb 2019 08:23:40 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y13sm4448994ioa.56.2019.02.11.08.23.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:23:39 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGNcot029952;
        Mon, 11 Feb 2019 16:23:38 GMT
Subject: [PATCH v1 00/23] NFS client patches for v5.1 (complete)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:23:38 -0500
Message-ID: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Anna-

Here's the complete series of my patches that are ready for the v5.1
merge window. All of them have been previously posted for review.
There are four main sets:

 - the first three are RPC-over-RDMA-related fixes
 - the next seven are observability improvements
 - the next eight overhaul the RPC auth layer to use xdr_stream
 - the last five reduce the size of RPC receive buffers

---

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


 fs/lockd/clnt4xdr.c                        |   14 -
 fs/lockd/clntxdr.c                         |   14 -
 fs/nfs/callback_xdr.c                      |   64 +--
 fs/nfs/flexfilelayout/flexfilelayout.c     |    2 
 fs/nfs/nfs2xdr.c                           |  124 ++----
 fs/nfs/nfs3xdr.c                           |  209 +++--------
 fs/nfs/nfs42xdr.c                          |   21 -
 fs/nfs/nfs4trace.h                         |   25 +
 fs/nfs/nfs4xdr.c                           |  529 ++++++++-------------------
 fs/nfs/nfstrace.c                          |    1 
 fs/nfs/nfstrace.h                          |   85 ++++
 fs/nfsd/nfs4callback.c                     |   13 -
 include/linux/sunrpc/auth.h                |   44 +-
 include/linux/sunrpc/clnt.h                |    3 
 include/linux/sunrpc/gss_krb5_enctypes.h   |   42 ++
 include/linux/sunrpc/xdr.h                 |   23 +
 include/linux/sunrpc/xprt.h                |    7 
 include/trace/events/rpcgss.h              |  361 ++++++++++++++++++
 include/trace/events/rpcrdma.h             |   12 +
 include/trace/events/sunrpc.h              |  361 ++++++++++++++++++
 net/sunrpc/Kconfig                         |   16 +
 net/sunrpc/auth.c                          |  136 ++++---
 net/sunrpc/auth_gss/Makefile               |    2 
 net/sunrpc/auth_gss/auth_gss.c             |  551 ++++++++++++++--------------
 net/sunrpc/auth_gss/gss_krb5_mech.c        |   29 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c        |    8 
 net/sunrpc/auth_gss/gss_mech_switch.c      |   27 -
 net/sunrpc/auth_gss/gss_rpc_upcall.c       |   15 -
 net/sunrpc/auth_gss/gss_rpc_upcall.h       |   16 -
 net/sunrpc/auth_gss/gss_rpc_xdr.c          |   15 -
 net/sunrpc/auth_gss/gss_rpc_xdr.h          |   17 -
 net/sunrpc/auth_gss/svcauth_gss.c          |    3 
 net/sunrpc/auth_gss/trace.c                |   11 +
 net/sunrpc/auth_null.c                     |   56 ++-
 net/sunrpc/auth_unix.c                     |  120 ++++--
 net/sunrpc/clnt.c                          |  390 ++++++++++----------
 net/sunrpc/svc.c                           |   19 -
 net/sunrpc/xdr.c                           |  121 +++---
 net/sunrpc/xprt.c                          |   10 -
 net/sunrpc/xprtrdma/backchannel.c          |    2 
 net/sunrpc/xprtrdma/frwr_ops.c             |    4 
 net/sunrpc/xprtrdma/rpc_rdma.c             |   22 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |    1 
 net/sunrpc/xprtrdma/verbs.c                |    2 
 net/sunrpc/xprtrdma/xprt_rdma.h            |   12 +
 net/sunrpc/xprtsock.c                      |   91 +++--
 47 files changed, 2071 insertions(+), 1580 deletions(-)
 create mode 100644 include/trace/events/rpcgss.h
 create mode 100644 net/sunrpc/auth_gss/trace.c

--
Chuck Lever

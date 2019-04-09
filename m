Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9914C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7975B21473
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cQGJRp0D"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726554AbfDIQPv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 12:15:51 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:37726 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726515AbfDIQPv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 12:15:51 -0400
Received: by mail-it1-f193.google.com with SMTP id u65so5871367itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 09:15:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=IWnSEZigajx9giRsc2yvg9Os5TcKao/aWvMbjXmu9Bw=;
        b=cQGJRp0Dr2Wf6c+o5Uc0u0yyI/jVjEnsAO3P0/r6T1vLI+6Sy9xYboCPrPKOJMQRQu
         slXuFfOzUVhawN8DWjKcZzd6hoSxnZ1ljtQ1jnAbKnhWXDwkBXTNpGWYJXjA3sg4TOxf
         wakr0mmiU5HJqmDneBCgcZQvbKLWVpGb7s4irKXIv8A9EF8dlcgsWc9d6yfPHi5zO2eY
         Y2pWRUZcCG/gOSGdA/45NvTFCEAt5xLToyvvAxCw4+jcu9MKNjtQEJuwcLeCbwrpCTgd
         b11uXGomT7ENhReK3BwBrcrJUwDXfoBARlKxDsm/YMf25FPMWLzx/aug8vqb7Nzmpepx
         j2pA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=IWnSEZigajx9giRsc2yvg9Os5TcKao/aWvMbjXmu9Bw=;
        b=NLQ5Vjgdoe/CoZsQlpwXpgMLzvfFxn8Xdr8DlawT6uSnQg6mjLJd1quCF2pOFONdxW
         SrBzc88jhnZwx8UykALAczcQ25Qh4bYagh6LUb/cR3O6McU9vr83Sy1bCa3zQUJQ+FQh
         Le79Su9PIMy3rf7tfNlOgnicWfS4AHhSNVr2ABy5+zxd2KOqHdD7B5fjT/lOeyGYjHYC
         x3+7sblBmgZckvmElQADQ/31oQWMUtdnuz4eAZqynzRUKtIINijUPwKggMMhPigS+2sR
         UxUFWghJeXHmYSQQ7c+l6qDbKyZO516bg0x6S8TqWunLuAeWcnGuISCPC4itupMDrbnD
         g9Iw==
X-Gm-Message-State: APjAAAVDQs53ljeZzhPcCczUUoiJlkH/zwFrPEma0VlDg5WB7/I9liMt
        ePaBW+x3v35yqo4796gYBw==
X-Google-Smtp-Source: APXvYqybKMsEie4l5HEiKFFGVpaVxqraMdWhxM8nYM2soFSEhLX8tukT3D7SFMto2v6Y/dSzb4G3Cg==
X-Received: by 2002:a05:660c:38a:: with SMTP id x10mr22326545itj.12.1554826550188;
        Tue, 09 Apr 2019 09:15:50 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d133sm7402425ita.5.2019.04.09.09.15.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 09:15:49 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] Make knfsd friendly to container uid/gid mapping
Date:   Tue,  9 Apr 2019 12:13:36 -0400
Message-Id: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The following patchset attempts to make knfsd more friendly to
containers that are set up with container-level uid/gid mapping. The
principles used are as follows:

- Assume upcalls for idmapping and RPCSEC_GSS should make use of the
  user namespace of the idmapper/rpcsec_gss daemon, which can be
  extracted from the cred used to open the upcall/downcall pseudo file.
- Assume downcalls may use the current_user_ns(), since the process
  context is that of the userland daemon that performs the downcall.
- Assume that wire protocols are mapped with of the user namespace of
  the process that started the knfsd server in the first place.
  i.e. that AUTH_UNIX and possibly the SETATTR/GETATTR uids and gids
  belong to the same user namespace as the process that started knfsd.
  This should ensure that knfsd matches the behaviour of a generic
  userspace NFS server running in the same circumstances.

---
v2: Temporary server sockets need to inherit the cred from their parent

Trond Myklebust (6):
  SUNRPC: Cache the process user cred in the RPC server listener
  SUNRPC: Temporary sockets should inherit the cred from their parent
  lockd: Pass the user cred from knfsd when starting the lockd server
  SUNRPC: Fix the server AUTH_UNIX userspace mappings
  SUNRPC: rsi_parse() should use the current user namespace
  nfsd: knfsd must use the container user namespace

 fs/lockd/clntlock.c               |  4 ++--
 fs/lockd/svc.c                    | 29 +++++++++++++++++------------
 fs/nfs/callback.c                 |  7 +++++--
 fs/nfs/client.c                   |  1 +
 fs/nfsd/export.c                  | 18 ++++++++++--------
 fs/nfsd/nfs3xdr.c                 | 21 +++++++++++----------
 fs/nfsd/nfs4idmap.c               |  8 ++++----
 fs/nfsd/nfs4xdr.c                 |  5 +++--
 fs/nfsd/nfsctl.c                  | 16 ++++++++--------
 fs/nfsd/nfsd.h                    |  9 ++++++++-
 fs/nfsd/nfssvc.c                  | 16 ++++++++--------
 fs/nfsd/nfsxdr.c                  | 17 +++++++++--------
 include/linux/lockd/bind.h        |  3 ++-
 include/linux/sunrpc/svc_xprt.h   |  4 +++-
 include/linux/sunrpc/svcsock.h    |  3 ++-
 net/sunrpc/auth_gss/svcauth_gss.c |  6 +++---
 net/sunrpc/svc_xprt.c             | 17 +++++++++++------
 net/sunrpc/svcauth_unix.c         | 15 +++++++++------
 net/sunrpc/svcsock.c              |  4 +++-
 19 files changed, 119 insertions(+), 84 deletions(-)

-- 
2.20.1


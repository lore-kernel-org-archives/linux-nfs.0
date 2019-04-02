Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88C27C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 50872207E0
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iiMsAvaw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726199AbfDBXqT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:46:19 -0400
Received: from mail-pl1-f195.google.com ([209.85.214.195]:32769 "EHLO
        mail-pl1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXqT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:46:19 -0400
Received: by mail-pl1-f195.google.com with SMTP id t16so5170162plo.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:46:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=wNMxlLwtJo0ZtRQ6euGBMIU1ye0iVDDqySX7KU/3mNA=;
        b=iiMsAvawql4buDjDUxXMIG/LBMA0Z4nxrQNo036y1jhqzAB+/87j6UMk62GS0M8yN3
         DDVPQAYGMcVjxU2JyjQGSS0utjSHozkj9E32Ar/QMT+PQYn78e/RyuRw8QD8ZHZyiM3O
         duBtGI/mIB9VUg5Nng9OLT2Dh/lGg+evJ20K0BskBGK2c76vc9rRN5QudtF7HU690D+X
         URhtKhjBLHKEpxuVJoEMsRaXY4Itf01OeH8uPJMBNdwgljoxypxg62CWLJI8dax/QJ6z
         Uzgsyf7IaUW95f9TIAUFIJcXMxlb7KwpBm8ewakKqbDe/2rcHJXUiWKHVFzEB7hHUZTV
         uUzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=wNMxlLwtJo0ZtRQ6euGBMIU1ye0iVDDqySX7KU/3mNA=;
        b=XN6F3v5oLxKvrlF8Lk8D3+WdQ5vZfTIqk/Weuu+H8GhdRnNPRdNlcowZtUDkyb4vKw
         1BdMZxmWzHwXFWNt3d2WjSybC3buG8Beqp5/nsHSaCVh9353thb3djM2B8tQBtp5mzod
         gbNrA8KpA/eH9APmNZyZ/XwqbdO3rWL+pJC3sljV819SIO39ujvhnAY2IHCigH0V/SUh
         UUxFgO6y02yK58HLaImXZEeVeP4y2C4DXi1M7gBqEnUPSffNXUsIBmDy6Kf3JnMd4eM2
         /Vz5B4pTdbNi0dT450RhAAIJ1+V0XDjCNeCBDYOLRsUcMnAiiaRqYmp2qJkH3V8gO6Rl
         wjjQ==
X-Gm-Message-State: APjAAAXLnBKFsdTgS2pRUEykWMvp1YRh+yuz41UOrkQkXORK74s29xsn
        akf5Ge8UYHkLBLInBA0yWRmjIR0=
X-Google-Smtp-Source: APXvYqzT6aRSzb1QnWg97qQ8YU+iJeBxudJ68Q4RQZstLw+kBUd516CH9DoOayvwc8eH/ltJaAM86w==
X-Received: by 2002:a17:902:248:: with SMTP id 66mr74295170plc.286.1554248778733;
        Tue, 02 Apr 2019 16:46:18 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y12sm38011643pgq.64.2019.04.02.16.46.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:46:17 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Make knfsd friendly to container uid/gid mapping
Date:   Tue,  2 Apr 2019 16:44:06 -0700
Message-Id: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
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

Trond Myklebust (5):
  SUNRPC: Cache the process user cred in the RPC server listener
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
 net/sunrpc/svc_xprt.c             | 12 ++++++++----
 net/sunrpc/svcauth_unix.c         | 15 +++++++++------
 net/sunrpc/svcsock.c              |  4 +++-
 19 files changed, 116 insertions(+), 82 deletions(-)

-- 
2.20.1


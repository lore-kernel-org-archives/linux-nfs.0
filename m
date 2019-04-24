Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92E5CC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 617A520811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AdANydrs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730583AbfDXVtB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:01 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:35733 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:01 -0400
Received: by mail-it1-f196.google.com with SMTP id w15so8887291itc.0
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=TOQQwmxS7CzbaXYJdL1j4Zsqbj7uNDphh88FFJiwscw=;
        b=AdANydrshod+mee6mjnzVmzzj8HEN+rBr8eCDERAp9fBrL35O3T7hnc/ZxiQuBCR5y
         WsYzq5Cqp2yGi1QhhLXROuK/XBSXchTFIZvi8bI1Lr+7GIkfZvhyXft7ULBWaDLc1UQn
         ZvMKAbj0yQZAHJoxvwObt8S7VIhldjSkBaOh5Ix5XkssP/2fpcBigmqsG+3MF+EOQLyG
         ZUYxATGNvGPgHa+X7BBzTlueyYer9VnmF6/956s7I+N30tgRCzb67M7IxwthVncI8IRL
         6mdQ70k4i+7uldthnoRkH7Qgk01plm+uspsU0fwqJ20Ze4hO4c6wofPqlCbha1wj0dQD
         aEtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=TOQQwmxS7CzbaXYJdL1j4Zsqbj7uNDphh88FFJiwscw=;
        b=c/8i4uk8YA4aWqjoD1lgJ99Bis/ldcSbbJ2OipNbuqKyNB+nz0+n2OMmtbL0n0ukq3
         kySCQyO4gwUvz8DBq6PnX0E2hboxtZQ4U2pjL+gNsSEieB4eB1LJwyV6we3D8ursRScz
         TU/eZ62FP55vAnBm5NbsVkU6k7abcd5fDOf8KiPUFMxvV/3QkM+C7/Ay1sp17PCgAQY8
         opbE9vmjNqSzVyS8/vqmDHGL/lfWF/FKYmARREmqnqgoGJR2oPNA+BWLd5hTAVOb4IuD
         GhUxoaZn0z1iX7RrlUOJxQ6NiDzjh4sxUMjjmRopXhs70bdvo7r+DtRcUt7TitBy0gDk
         r7LQ==
X-Gm-Message-State: APjAAAXVmw97pCFBP7UQpLkf9wqydyc2AARqnTTKi/WYI7xUFJt5R+DX
        H9Evp0Wow4U0DUPyl/zmCg==
X-Google-Smtp-Source: APXvYqwp8jsbPBhjs7v5rE9OKI7n9GA8KHSLjD2td2J2xdIkt2UN2lo3Wc9+qqSex7qoxmWVslAZgQ==
X-Received: by 2002:a24:628b:: with SMTP id d133mr1113498itc.32.1556142539961;
        Wed, 24 Apr 2019 14:48:59 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.48.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:48:58 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] Client container fixes
Date:   Wed, 24 Apr 2019 17:46:41 -0400
Message-Id: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch set aims to fix up the NFS client when invoked from inside a
container. It aims to ensure that upcalls use the correct user namespace
when talking to the rpc.gssd and rpc.idmapd daemons.

Trond Myklebust (9):
  SUNRPC: Cache cred of process creating the rpc_client
  NFS: Store the credential of the mount process in the nfs_server
  SUNRPC: Use the client user namespace when encoding creds
  SUNRPC: Use namespace of listening daemon in the client AUTH_GSS
    upcall
  NFS: Convert NFSv3 to use the container user namespace
  NFSv4: Convert the NFS client idmapper to use the container user
    namespace
  NFS: Convert NFSv2 to use the container user namespace
  NFS: When mounting, don't share filesystems between different user
    namespaces
  lockd: Store the lockd client credential in struct nlm_host

 fs/lockd/clntlock.c            |   2 +-
 fs/lockd/host.c                |  10 ++-
 fs/lockd/mon.c                 |   1 +
 fs/nfs/client.c                |   7 ++
 fs/nfs/internal.h              |   1 +
 fs/nfs/mount_clnt.c            |   2 +
 fs/nfs/nfs2xdr.c               |  58 +++++++++-----
 fs/nfs/nfs3client.c            |   1 +
 fs/nfs/nfs3xdr.c               | 142 ++++++++++++++++++++-------------
 fs/nfs/nfs4client.c            |   6 ++
 fs/nfs/nfs4idmap.c             |  27 +++++--
 fs/nfs/super.c                 |  17 ++++
 fs/nfsd/nfs4callback.c         |   1 +
 include/linux/lockd/bind.h     |   1 +
 include/linux/lockd/lockd.h    |   4 +-
 include/linux/nfs_fs_sb.h      |   3 +
 include/linux/sunrpc/clnt.h    |   2 +
 net/sunrpc/auth_gss/auth_gss.c |  63 +++++++++++----
 net/sunrpc/auth_unix.c         |   9 ++-
 net/sunrpc/clnt.c              |   7 ++
 net/sunrpc/rpcb_clnt.c         |   9 ++-
 21 files changed, 267 insertions(+), 106 deletions(-)

-- 
2.21.0


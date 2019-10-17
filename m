Return-Path: <SRS0=AtwM=YK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1371ECE58E
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 13:05:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8CE0E20640
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 13:05:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GOWQ/2M2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732510AbfJQNFv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Oct 2019 09:05:51 -0400
Received: from mail-qk1-f193.google.com ([209.85.222.193]:41238 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726898AbfJQNFu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2019 09:05:50 -0400
Received: by mail-qk1-f193.google.com with SMTP id p10so1752242qkg.8
        for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2019 06:05:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=l9DtJA0P+HbKyHsdtq1Ea2p+bmaxcOuWEQj1qUxK2T0=;
        b=GOWQ/2M2nfrbE2cTQ5dMT9734EYJoawhR9Rb+r8BbPGd1J7XvDCFPgO4Zc+I5z+1yc
         +piFpv+YpXM0yhkrMQxOIE5LEg4yYbcVSknDY/zBolI6kT4zuUmozasU5UApA8qagCXL
         b2+AEGSUcezfgFvBA+bFbPry2wgS4VzN2iveNZ3Op1xoWUNLDbHED/1b6XeGn0f65hgi
         ZOXnai8cTDG5SuzBma9+J1LkCDdnSphy+rLR6ptOU00PZy+vfWz4TQVTvisiQrmT2ZGE
         6xSq70nHGw5RDNieaDQv2vRR9nK4PX00nDHM5AhliUoqfcD4+KcTtTnSmaPpBOBqQgXz
         3Q0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=l9DtJA0P+HbKyHsdtq1Ea2p+bmaxcOuWEQj1qUxK2T0=;
        b=qoqc4tJll/zQGpQYCMS/69vKT00t7hZ2vi3b08wCNIhefLwUpDdfuwLax6niixkxdn
         tsSzAIKrvf+SXJIsyDDp827ANshnSgoh8Tt5KNWQd65fBaQc6IWM3sgiImXtswm1Tk6K
         4tsyLG5f2bwHhUv4FHv2sy+qj16Fx5x0KPCz22CwfS8dSiOQpPgaMdlDwQm0sNDmGI2+
         k7v5ZSi6lmIqKw9lTQwuu11Okjk5gItOX740RsS8SbaWQNV9wZtHe3htdBDe1cBonK5u
         M0xqSZQjjGbH95we5ikxr5mmxI8wNXTRBkgi6VF8qMQDhV337d6SEz6fACDXSkcPmHri
         dPsQ==
X-Gm-Message-State: APjAAAX6MiV6Xi/Nm27tngESu35TddrEnvw44ummQ1s65g4mwc8tQ5gH
        zSQt6DdopnboOV/Ulk2npfX5VtM=
X-Google-Smtp-Source: APXvYqzQsyt59TJl+SlnWtULRtZ4JqkE7gU+4bRnV8WWFRlOw5YAiRpIhf8XFDxACpchHNoJMHsjEg==
X-Received: by 2002:a37:bbc4:: with SMTP id l187mr3237300qkf.50.1571317549321;
        Thu, 17 Oct 2019 06:05:49 -0700 (PDT)
Received: from localhost.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id g194sm1326648qke.46.2019.10.17.06.05.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 17 Oct 2019 06:05:48 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Cc:     Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH v2 0/3] Backchannel fixes
Date:   Thu, 17 Oct 2019 09:02:18 -0400
Message-Id: <20191017130221.7924-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A set of patches to ensure the backchannel lifetime cannot exceed the
lifetime of the transport to which it is attached.

v2:
 - Fix the case where !defined(CONFIG_SUNRPC_BACKCHANNEL)
 - Don't allow xprt->bc_alloc_max to underflow in xprt_destroy_bc()

Trond Myklebust (3):
  SUNRPC: The TCP back channel mustn't disappear while requests are
    outstanding
  SUNRPC: The RDMA back channel mustn't disappear while requests are
    outstanding
  SUNRPC: Destroy the back channel when we destroy the host transport

 include/linux/sunrpc/bc_xprt.h    | 5 +++++
 net/sunrpc/backchannel_rqst.c     | 7 ++++---
 net/sunrpc/xprt.c                 | 5 +++++
 net/sunrpc/xprtrdma/backchannel.c | 2 ++
 4 files changed, 16 insertions(+), 3 deletions(-)

-- 
2.21.0


Return-Path: <SRS0=N5nt=2A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E501AC43603
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Dec 2019 20:29:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B507B2073D
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Dec 2019 20:29:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nAzSmZuR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726682AbfLJU3q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 Dec 2019 15:29:46 -0500
Received: from mail-yw1-f66.google.com ([209.85.161.66]:41237 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726589AbfLJU3q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2019 15:29:46 -0500
Received: by mail-yw1-f66.google.com with SMTP id l22so7831208ywc.8
        for <linux-nfs@vger.kernel.org>; Tue, 10 Dec 2019 12:29:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=16Yd6aY8YBgFiSCHA0icskP/AMX1AsNAz6GKG5gYC40=;
        b=nAzSmZuRCfASmJGlbehG3OS16g7ah8kReubqMeGdDCzQTFgDQpxO9GS9fTKdV2zMfY
         Ja9+6OXuzpmkzkxzk7yHsukgdn/sBm1Ww3fF4lJYPOSIoo5jKW6q5wo87DbNDXbR9y1a
         6aMiCE24GZqxqHpj10FB0CmTvApSrx3uRjND9eTyRfsXHg9XYOMC+C08v1Rc88zhoy+H
         +xZ+ZEa2xSUagE0bXaOy/UnCGqGR3gPEhkTfrThFOJjcdU8FCTDYtJJpsYiKloOdtvOk
         5dNkbqvU7za2IdWMKPSHs69lID80Zm61sBY+Kd5MKBrYAYIlg3Y/Wus3ECRAaCSroGUR
         X2fg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=16Yd6aY8YBgFiSCHA0icskP/AMX1AsNAz6GKG5gYC40=;
        b=RwJDeCM+xdM0kY1ktBOAbyaO19Uv3oewDhMQvgdvp8XGT5bDzu9ez6iQcNXOiuqK7r
         LGuTEbgsqTLcpf1fSrRcvcwwppyMezTBiSM2LXjN7VaHuynHhrTQJ+iYzf4fn73wCMGM
         yKGdSb9T/NtcnnmQDGWm0nvttOgm/xTqF+KIsYBljy5k6MS+UTnxqBgYogaA/LMPvYhx
         HsWoDxWO4XKc7ninyZJYOIQAK1y5hUv+dGgCvZsumR4Us9GA7jOXxHbmDfmDgE+ZIp/M
         nPNZXdWMr+DULecUQZPpS2Dr7fpfnyngO5OwbJfEDZlwb1Kjjsh0oSMZwAnSLl2Ml/Pf
         UrPQ==
X-Gm-Message-State: APjAAAU6DPEZE7FWERLVtrlpQl2x7jYT2GafC6R6pGCwKXAcMCijXZ7p
        3qVIy9l+OKxbWOXJykz+NMt4nsg=
X-Google-Smtp-Source: APXvYqy2istd/eci+vJ5qDyH81445wwjENfmFMe/i/mqN3CECZ9Dovn625EOY5UDXInLQFdsRzI7Xg==
X-Received: by 2002:a81:b60d:: with SMTP id u13mr11265044ywh.382.1576009784710;
        Tue, 10 Dec 2019 12:29:44 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x84sm1947508ywg.47.2019.12.10.12.29.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Dec 2019 12:29:44 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] Improve performance of containerised knfsd
Date:   Tue, 10 Dec 2019 15:27:29 -0500
Message-Id: <20191210202735.304477-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The following patches fix up the garbage collection for the knfsd file
cache, to make the behaviour under load be more predictable.
It also separates out the garbage collectors for knfsd instances running
under different containers to ensure that a close() or fput() of a file
in one container that hangs or is slow won't gum up the system for
all the other containers.

Trond Myklebust (6):
  nfsd: fix filecache lookup
  nfsd: cleanup nfsd_file_lru_dispose()
  nfsd: Containerise filecache laundrette
  nfsd: Remove unused constant NFSD_FILE_LRU_RESCAN
  nfsd: Schedule the laundrette regularly irrespective of file errors
  nfsd: Reduce the number of calls to nfsd_file_gc()

 fs/nfsd/filecache.c | 285 ++++++++++++++++++++++++++++++++++----------
 fs/nfsd/filecache.h |   2 +
 fs/nfsd/nfssvc.c    |   9 +-
 3 files changed, 230 insertions(+), 66 deletions(-)

-- 
2.23.0


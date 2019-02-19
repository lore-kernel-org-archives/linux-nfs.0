Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10FFDC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D472C2147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IBYEJCmf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726180AbfBSNzP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:15 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36414 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfBSNzO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:14 -0500
Received: by mail-it1-f193.google.com with SMTP id h6so6316484itl.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=n7rYUlXXCxL3WNhYoIIF0l7D8roaSMLBHhAGsRfKRuU=;
        b=IBYEJCmfB0zZt2l7ctVYzpvH7om9KSZoh3XfmXt5CujwjslnxPtj1EBXy5FuMctgov
         4ag1Jhu04R7rvru+o9C9ecbiTEEI6w18OIEEhDzDtLd+IzZfD3rxoLmOy7OJG2VyOUF5
         ffOKGjZZHjmEiw2Qnh1K4Nepz9b6w2BFnnT+WXgDaJZtGM55yW6haCh3JOWxIpjdZHOP
         s/wkreTA0vEGMgve2ER71Jux/tncaeo93PW+ROsAkk3QKqqDlhvB5yBqwFWWRNSwFxK8
         Pn108RI7w5i8tvt7hHGrs1mBUQHyb8B2ijSoWCA5tCWs6VSK6ew8WksQfarPgRWlpREe
         k6ew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=n7rYUlXXCxL3WNhYoIIF0l7D8roaSMLBHhAGsRfKRuU=;
        b=OuI9FT5MTgMsZsd2QOyg0NSOFg/Bosm22wFrRaIQlSqfIDgGpaxFnXuPw9VmeVuFYA
         uuy5244WgCptS+KobOKP/cwI8o8V7JofgV2UNo6atgx3k3BTEIgq7RuXYFuc/JRR1M/S
         5YWMb5K9vAtfQy3vwUVDe8/9HB1Azf1KkbKyqGL2qzUY4txopLyKZ8fO7nUEu+SJx8UT
         pDDFYS6f8w8rjYmiQkDP0GAMH2uxM1+N0EF2YZdLiqk6b1KdWZYn3G6S+vx5lpmf/sKh
         Btq+49oPje85GvLf/SlWucmmFWc9UJVLtjDessrR9PRzAuMtlsyNIourBIILCtWpZvhE
         AUGw==
X-Gm-Message-State: AHQUAuaXH5bHaCNfZWS9t4Y6z/BwQAscB6zCb8yhsJ5+2Gmw8qXlVgSg
        ETHWzMDO420q/gBPP/wze10XDjs=
X-Google-Smtp-Source: AHgI3IaHxIttdp5Iu749qPftVvahClCi9rPWxMcfZdO2fQhF5SlG7TDutPCIbumF9RMFNYvZFFZ35A==
X-Received: by 2002:a24:17:: with SMTP id 23mr2586764ita.158.1550584513530;
        Tue, 19 Feb 2019 05:55:13 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:12 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/8] NFS file I/O bugfixes and cleanups
Date:   Tue, 19 Feb 2019 08:53:03 -0500
Message-Id: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The main focus of this patchset is to address a set of I/O request
leakages that crept in during the NFSv4.0 file I/O changes. The
first 3 patches in the set are intended as stable patches in order
to address these issues.
In addition, there are a couple of clean ups, and some lesser bugfixes.

Trond Myklebust (8):
  NFS: Fix I/O request leakages
  NFS: Fix an I/O request leakage in nfs_do_recoalesce
  NFS: Don't recoalesce on error in nfs_pageio_complete_mirror()
  NFS: Clean up list moves of struct nfs_page
  NFS: Pass error information to the pgio error cleanup routine
  NFS: Ensure NFS writeback allocations don't recurse back into NFS.
  NFS: EINTR is also a fatal error.
  NFS: ENOMEM should also be a fatal error.

 fs/nfs/direct.c          |  7 +++----
 fs/nfs/internal.h        |  2 ++
 fs/nfs/pagelist.c        | 40 ++++++++++++++++++++++++++--------------
 fs/nfs/read.c            |  2 +-
 fs/nfs/write.c           | 18 +++++++++++++++---
 include/linux/nfs_page.h | 10 ++++++++++
 include/linux/nfs_xdr.h  |  2 +-
 7 files changed, 58 insertions(+), 23 deletions(-)

-- 
2.20.1


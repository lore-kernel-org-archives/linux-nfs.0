Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02537C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BFD152084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e+lV+dq7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725974AbfCAT0z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:26:55 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:46389 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725862AbfCAT0z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:26:55 -0500
Received: by mail-yw1-f68.google.com with SMTP id n12so14911074ywn.13
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=u7uwen2p6wHrAWzMTcDbfyqAS6Nsp1mZf2z1Zy6ERw8=;
        b=e+lV+dq7u2uE8mIjbpd6PSHdMaRr7FqrzTGdLup72UY0bdNNqnSPNqcXS9y+/E428M
         vH+rtf9HUaRZ1QW6Lk4LvO/jPeJ20sS3jWSZRoqGgZNoK0s5VtXuRsIiIjktXEi+03hO
         EKajuccroXaXoSz6xIBEaXHfVKNIWMBziM4RGupy+NWqtniy3gohTSoQk+3Nr1pvBGev
         mH0tWq8wV+06B5Zyd2KENQ8IGnqWt/L8jQYen5XSNlsOURwAOEuJY5vNbl/W/fGGbQGv
         tdvXGiIcdhRmWDDl49ak1AUrs7/1CkCgvxqBef+SXTI43k/D+rb+okxKNOGjtihMDlXi
         UNqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=u7uwen2p6wHrAWzMTcDbfyqAS6Nsp1mZf2z1Zy6ERw8=;
        b=rz6VnIE9uSCsUDKa2B2CANAbJLLHNmeuArsXf4v41MiH1YYo6Lnx0qW2LbR+NEpiis
         oxfomQmmX8nc8nwwSfPt7Mb2aRP5KrxSR5e+ZjLFjWbA1ovYz3N41NheNscr7NUXLEPq
         Zb2B9kZ+KQ6BI6qnprXqN35cRnFI5Vb8wqMt/IjzS4X3sgLmtgDC35hAqLxZc7fW6XYj
         WpQ/HmVxlDNmG2USHuw9g/9shjjGZ3OO/wsaA7O+ng66wtM3eYrCq57Vvj4xR2Q1KRGq
         4OCdK/9W9xRMKeXbWt1BZqNiLVnktMma2EDrW4SOZnVmBhpUBRWbW6+J2qsk5UIX3/Pr
         KOPA==
X-Gm-Message-State: APjAAAXF4sxz7bVHa0QgiAytqC+ci2iHvnHsfjgFihpbj4K3bIgKhdX3
        T9+b6mI1dVQSCEF2iIVnMRUzyiw=
X-Google-Smtp-Source: APXvYqwJtw6MpDCPrF5XZ/0XHIBnb7bdkAgeOVu5KOhuH2y5xI9JjbHQaxcSKf254TzYDOKBmKuyaQ==
X-Received: by 2002:a25:9c82:: with SMTP id y2mr5666472ybo.435.1551468413225;
        Fri, 01 Mar 2019 11:26:53 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:52 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 00/19] Updates for pNFS/flexfiles
Date:   Fri,  1 Mar 2019 14:24:36 -0500
Message-Id: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The following patches update the pNFS/flexfiles layout driver.
The main feature enhancements revolve around adding support for
the NFSv4.2 LAYOUTERROR operation. This was seen as necessary
in order to fix a livelock issue that can occur if the client
has lots of outstanding I/O, but the DS is down.
In that case, we currently file an error that is supposed to get
sent to the server as part of LAYOUTRETURN. However if the I/O
retries are occurring quickly enough so that we keep renewing
the layout, then we end up never being able to send the
layoutreturn,  the server ends up never getting notified about
the error condition, and just keeps handing out the same
layout over and over again in response to new LAYOUTGETs.
By sending the LAYOUTERROR without needing to return the layout,
we can break the cycle.

Trond Myklebust (19):
  NFSv4/flexfiles: Fix invalid deref in FF_LAYOUT_DEVID_NODE()
  NFS/flexfiles: Fix up sparse RCU annotations
  NFSv4/pnfs: Fix barriers in nfs4_mark_deviceid_unavailable()
  NFSv4/flexfiles: Abort I/O early if the layout segment was invalidated
  NFSv4.2: Add client support for the generic 'layouterror' RPC call
  NFS/flexfiles: Send LAYOUTERROR when failing over mirrored reads
  NFSv4: Handle early exit in layoutget by returning an error
  NFS/flexfiles: refactor calls to fs4_ff_layout_prepare_ds()
  NFS/flexfiles: Avoid unnecessary layout invalidations
  NFS/flexfiles: Remove bogus checks for invalid deviceids
  NFS/flexfiles: Don't invalidate DS deviceids for being unresponsive
  NFS/flexfiles: Speed up read failover when DSes are down
  NFS/flexfiles: Simplify nfs4_ff_layout_select_ds_fh()
  NFS/flexfiles: Simplify nfs4_ff_find_or_create_ds_client()
  NFS/flexfiles: Simplify ff_layout_get_ds_cred()
  NFS/flexfile: Simplify nfs4_ff_layout_ds_version()
  NFS/flexfile: Simplify nfs4_ff_layout_select_ds_stateid()
  NFS/flexfiles: Remove dead code in ff_layout_mirror_valid()
  NFS/flexfiles: Clean up mirror DS initialisation

 fs/nfs/flexfilelayout/flexfilelayout.c    | 216 ++++++++++++++++------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  75 ++++----
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 150 +++++----------
 fs/nfs/nfs42.h                            |   3 +
 fs/nfs/nfs42proc.c                        | 164 ++++++++++++++++
 fs/nfs/nfs42xdr.c                         |  99 ++++++++++
 fs/nfs/nfs4proc.c                         |   9 +-
 fs/nfs/nfs4xdr.c                          |   1 +
 fs/nfs/pnfs.h                             |   1 +
 fs/nfs/pnfs_dev.c                         |  13 ++
 include/linux/nfs4.h                      |   1 +
 include/linux/nfs_fs_sb.h                 |   1 +
 include/linux/nfs_xdr.h                   |  35 ++++
 include/linux/sunrpc/sched.h              |   1 +
 net/sunrpc/xprt.c                         |   7 +
 15 files changed, 571 insertions(+), 205 deletions(-)

-- 
2.20.1


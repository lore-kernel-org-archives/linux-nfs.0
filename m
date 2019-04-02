Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46D20C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:16:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 130D020700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:16:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p4/YZFv0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725912AbfDBXQ6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:16:58 -0400
Received: from mail-pl1-f194.google.com ([209.85.214.194]:39229 "EHLO
        mail-pl1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXQ6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:16:58 -0400
Received: by mail-pl1-f194.google.com with SMTP id b65so7015559plb.6
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:16:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=bWQxvlFBceKlEwM+YS3xCooATFVwFU/uPGhMmPAaHEA=;
        b=p4/YZFv0ttk0IBf+veRgdpkL/fzTqv5eAxsMn+KCZedmOmCWgnQtWA630uMGpzsqAz
         V32I5NSymDuq1aFBt2IFi9Pr/rn9/GOA/mt0Q+lVAHzjnDSYi5nILGYtnSUISID5M4A3
         9zxQl4QWF4EPGM4w6ES65Y6x4BrYUJqMrrFP+CXXTBFPr+9s8b8xaVaU63hBzy8uquKp
         NxtjGZ7U3xGsgO35nzASsYRqdSDtDas47i2Cv53Q9hD9rnRRVZJBTEWgSEWhOg16qe4n
         Tpb62uEwPTX8Tfq24fzlXqGCBRDpYrh9VCADpJL5AZFRQgbgavH4lLjKXTAneIbrtrip
         OHbA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=bWQxvlFBceKlEwM+YS3xCooATFVwFU/uPGhMmPAaHEA=;
        b=YbG40AViUn5fcHC2SNNFPUzHXAdrfEo3Wk5pseZnuwHG/wo/Jok2Z98bxjuclHONr0
         77cPTj8ZQrt8oSe+FYT9A5aZmlvNtn+14RpIrd7i23WuZQCNhu0u6r7Nb5sY9Y4yWKqT
         eiPUdaalxl624lvw8PtI6HJjwcBzMD1oh0KV2q0kvC+EIeRCTSdfC8Z5kMRaBSA8tdCm
         h1wgh4GWMbjLnJn8GX6BoHEJiPTBkT8SicZgSEYCpueOEfI/hYSZdGz960owLTmDwh8b
         2V5wl74O05AvVO0+EVHUADRlcCqxPzLlF7EJBMqeIPwXvcwHMSsX89RS8nhVHBEazpud
         K4zQ==
X-Gm-Message-State: APjAAAVDGop8THbONHAHMvz+cxQs+reyIF81omCb4c7COOtP9alm7tOC
        cHL+ZcP9xMFdGsQDCv5lAg==
X-Google-Smtp-Source: APXvYqyTsFZSuxx3vJ++jYELmj7IihwRaXi+Y4K56dQN7kdvdOSy2+mKFovFnvmkXJXxhGJBqW4Esw==
X-Received: by 2002:a17:902:2927:: with SMTP id g36mr45325894plb.57.1554247016998;
        Tue, 02 Apr 2019 16:16:56 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.16.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:16:55 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] Allow containerised knfsd to set supported NFS versions
Date:   Tue,  2 Apr 2019 16:14:42 -0700
Message-Id: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The current knfsd implementation is unable to support containers that
want to run different combinations of NFS versions. This is because of
the way we define which versions are supported: by directly editing the
global version table in 'nfsd_program'.
The following patch set modifies the method used to define version
information by moving some of the server RPC request initialisation
down into knfsd itself, allowing it to manage the version-specific
initialisation.

Note that we might want to consider a few follow ups to this patchset
to get rid of some of the version-specific flags (e.g. vs_hidden) that
currently need to be managed in the generic SUNRPC server code on behalf
of just one or two RPC programs. These flags can easily by replaced by
custom RPC request initialisers.

Trond Myklebust (6):
  SUNRPC/nfs: Fix return value for nfs4_callback_compound()
  SUNRPC: Add a callback to initialise server requests
  SUNRPC: Clean up generic dispatcher code
  SUNRPC: Allow further customisation of RPC program registration
  nfsd: Add custom rpcbind callbacks for knfsd
  nfsd: Allow containers to set supported nfs versions

 fs/lockd/svc.c             |   4 +-
 fs/nfs/callback.c          |   2 +
 fs/nfs/callback_xdr.c      |   2 +-
 fs/nfsd/netns.h            |   8 +
 fs/nfsd/nfs4proc.c         |   3 +-
 fs/nfsd/nfsctl.c           |  25 +--
 fs/nfsd/nfsd.h             |   8 +-
 fs/nfsd/nfssvc.c           | 251 +++++++++++++++++++++++++-----
 include/linux/sunrpc/svc.h |  33 ++++
 net/sunrpc/svc.c           | 310 ++++++++++++++++++++++++-------------
 10 files changed, 480 insertions(+), 166 deletions(-)

-- 
2.20.1


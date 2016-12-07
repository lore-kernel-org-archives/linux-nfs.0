Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35560 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932339AbcLGUmf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2016 15:42:35 -0500
Received: by mail-io0-f174.google.com with SMTP id a124so733254785ioe.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2016 12:42:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Fix 2 more flexfiles issues
Date: Wed,  7 Dec 2016 15:42:24 -0500
Message-Id: <20161207204226.15927-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a use-after-free case and a list ordering issue.

Trond Myklebust (2):
  pNFS/flexfiles: Fix ff_layout_add_ds_error_locked()
  pNFS: Layoutreturn must free the layout after the layout-private data

 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 3 ++-
 fs/nfs/nfs4proc.c                         | 4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

-- 
2.9.3


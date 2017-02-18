Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35090 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753155AbdBRSSL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2017 13:18:11 -0500
Received: by mail-io0-f193.google.com with SMTP id m98so1704828iod.2
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2017 10:18:11 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] XDR cleanups for NFSv4
Date: Sat, 18 Feb 2017 13:18:02 -0500
Message-Id: <20170218181806.25712-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Various cleanups and bugfixes for the NFSv4 client XDR code

v2: Add documentation to the generic helpers

Trond Myklebust (4):
  SUNRPC: Add generic helpers for xdr_stream encode/decode
  NFSv4: Replace ad-hoc xdr encode/decode helpers with xdr_stream_*
    generics
  NFSv4: Fix the underestimation of delegation XDR space reservation
  NFSv4: Remove bogus "struct nfs_client" argument from decode_ace()

 fs/nfs/callback_xdr.c                  |   8 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |   5 +-
 fs/nfs/nfs4xdr.c                       |  58 ++++-------
 include/linux/sunrpc/xdr.h             | 171 +++++++++++++++++++++++++++++++++
 4 files changed, 193 insertions(+), 49 deletions(-)

-- 
2.9.3


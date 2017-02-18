Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32925 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753550AbdBRTMu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2017 14:12:50 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so6808250itc.0
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2017 11:12:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/4] XDR cleanups for NFSv4
Date: Sat, 18 Feb 2017 14:12:42 -0500
Message-Id: <20170218191246.32687-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Various cleanups and bugfixes for the NFSv4 client XDR code

v2: Add documentation to the generic helpers
v3: Fix a bug in xdr_stream_encode_opaque (Whoops!)

Trond Myklebust (4):
  SUNRPC: Add generic helpers for xdr_stream encode/decode
  NFSv4: Replace ad-hoc xdr encode/decode helpers with xdr_stream_*
    generics
  NFSv4: Fix the underestimation of delegation XDR space reservation
  NFSv4: Remove bogus "struct nfs_client" argument from decode_ace()

 fs/nfs/callback_xdr.c                  |   8 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |   5 +-
 fs/nfs/nfs4xdr.c                       |  58 ++++-------
 include/linux/sunrpc/xdr.h             | 173 +++++++++++++++++++++++++++++++++
 4 files changed, 195 insertions(+), 49 deletions(-)

-- 
2.9.3


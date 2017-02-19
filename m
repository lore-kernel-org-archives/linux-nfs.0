Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33660 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdBSS7H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 13:59:07 -0500
Received: by mail-io0-f176.google.com with SMTP id g18so16919357ioe.0
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 10:59:07 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/8] XDR cleanups for NFSv4
Date: Sun, 19 Feb 2017 13:58:55 -0500
Message-Id: <20170219185903.42043-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Various cleanups and bugfixes for the NFSv4 client XDR code.

v2: Add documentation to the generic helpers
v3: Fix a bug in xdr_stream_encode_opaque (Whoops!)
v4: Add a "maxlen" argument to xdr_stream_decode_opaque_inline() to perform
    size sanity checking on all objects coming from the server.
    Replace the string decoder in the callback XDR
    Add cleanups for the owner/group attribute decoding

Trond Myklebust (8):
  SUNRPC: Add generic helpers for xdr_stream encode/decode
  NFSv4: Replace ad-hoc xdr encode/decode helpers with xdr_stream_*
    generics
  NFSv4: Replace the open coded decode_opaque_inline() with the new
    generic
  NFSv4: Replace callback string decode function with a generic
  NFSv4: Fix the underestimation of delegation XDR space reservation
  NFSv4: Remove bogus "struct nfs_client" argument from decode_ace()
  SUNRPC: Add a helper function xdr_stream_decode_string_dup()
  NFSv4: Clean up owner/group attribute decode

 fs/nfs/callback_xdr.c                  |  38 ++-----
 fs/nfs/flexfilelayout/flexfilelayout.c |   5 +-
 fs/nfs/nfs4xdr.c                       | 185 ++++++++++++++-------------------
 include/linux/sunrpc/xdr.h             | 179 +++++++++++++++++++++++++++++++
 net/sunrpc/xdr.c                       |  34 ++++++
 5 files changed, 302 insertions(+), 139 deletions(-)

-- 
2.9.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34119 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbeCTVDl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:41 -0400
Received: by mail-io0-f170.google.com with SMTP id r18so4086650ioa.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] Misc cleanups
Date: Tue, 20 Mar 2018 17:03:04 -0400
Message-Id: <20180320210313.94429-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches are a set of cleanups for the NFSv4 XDR encoding
both on the forward and back channels.
Also a couple of delegation related cleanups and fixes.

Trond Myklebust (9):
  SUNRPC: Add helpers for decoding opaque and string types
  SUNRPC: Add a helper for encoding opaque data inline
  NFSv4: Allow GFP_NOIO sleeps in decode_attr_owner/decode_attr_group
  NFSv4; Clean up XDR encoding of type bitmap4
  NFSv4: Clean up encode_attrs
  NFSv4: Add a helper to encode/decode struct timespec
  NFSv4: Don't ask for attributes when ACCESS is protected by a
    delegation
  NFSv4: Clean up CB_GETATTR encoding
  NFSv4: Fix the nfs_inode_set_delegation() arguments

 fs/nfs/callback_xdr.c      |  37 ++-----
 fs/nfs/delegation.c        |  35 ++++---
 fs/nfs/delegation.h        |   6 +-
 fs/nfs/nfs4proc.c          |  25 +++--
 fs/nfs/nfs4xdr.c           | 238 +++++++++++++++++++++------------------------
 include/linux/sunrpc/xdr.h |  94 ++++++++++++++++++
 net/sunrpc/xdr.c           |  82 ++++++++++++++++
 7 files changed, 336 insertions(+), 181 deletions(-)

-- 
2.14.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:37671 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933258AbcKNUzj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 15:55:39 -0500
Received: by mail-it0-f52.google.com with SMTP id b123so50424927itb.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 12:55:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] Optimisations for state management
Date: Mon, 14 Nov 2016 15:55:30 -0500
Message-Id: <1479156935-34479-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches constitute a grab bag of minor optimisations when
the NFS client is managing its state.

v2: Fix "enumeration value 'NFS4_OPEN_CLAIM_PREVIOUS' not handled in switch"

Trond Myklebust (5):
  NFSv4: Don't check file access when reclaiming state
  NFSv4: Don't ask for the change attribute when reclaiming state
  NFSv4: Don't request a GETATTR on open_downgrade.
  NFSv4: Don't request close-to-open attribute when holding a delegation
  NFSv4: Optimise away forced revalidation when we know the attributes
    are OK

 fs/nfs/delegation.c |  4 ----
 fs/nfs/inode.c      |  2 +-
 fs/nfs/nfs4proc.c   | 25 +++++++++++++++++++------
 fs/nfs/nfs4xdr.c    |  7 ++-----
 4 files changed, 22 insertions(+), 16 deletions(-)

-- 
2.7.4


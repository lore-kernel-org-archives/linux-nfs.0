Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:34483 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934551AbcKJVlO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 16:41:14 -0500
Received: by mail-it0-f54.google.com with SMTP id q124so43029096itd.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2016 13:41:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Optimisations for state management
Date: Thu, 10 Nov 2016 16:41:05 -0500
Message-Id: <1478814070-17140-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches constitute a grab bag of minor optimisations when
the NFS client is managing its state.

Trond Myklebust (5):
  NFSv4: Don't check file access when reclaiming state
  NFSv4: Don't ask for the change attribute when reclaiming state
  NFSv4: Don't request a GETATTR on open_downgrade.
  NFSv4: Don't request close-to-open attribute when holding a delegation
  NFSv4: Optimise away forced revalidation when we know the attributes
    are OK

 fs/nfs/delegation.c |  4 ----
 fs/nfs/inode.c      |  2 +-
 fs/nfs/nfs4proc.c   | 23 +++++++++++++++++------
 fs/nfs/nfs4xdr.c    |  7 ++-----
 4 files changed, 20 insertions(+), 16 deletions(-)

-- 
2.7.4


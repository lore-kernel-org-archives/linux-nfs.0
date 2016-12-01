Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33904 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbcLAWGe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:06:34 -0500
Received: by mail-io0-f172.google.com with SMTP id c21so409916625ioj.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:06:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Performance optimsations for 4.10
Date: Thu,  1 Dec 2016 17:06:27 -0500
Message-Id: <20161201220632.12754-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series contains a set of minor optimisations that are mainly
useful against pNFS systems that may incur a higher performance penalty
on unnecessary attribute requests by triggering an internal RPC call from
the MDS to the DS.

- Speed up state recovery after a server reboot by avoiding unnecessary
  GETATTR and ACCESS checks.
- Avoid unnecessary attribute revalidations on operations such as
  OPEN_DOWNGRADE, where we don't yet need to update close-to-open
  cache consistency attributes.
- Avoid unnecessary attribute revalidations when we hold a delegation.

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
 fs/nfs/nfs4xdr.c    | 13 ++++---------
 4 files changed, 24 insertions(+), 20 deletions(-)

-- 
2.9.3


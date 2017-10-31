Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:54316 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751871AbdJaAJz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 20:09:55 -0400
Received: by mail-io0-f180.google.com with SMTP id e89so31184721ioi.11
        for <linux-nfs@vger.kernel.org>; Mon, 30 Oct 2017 17:09:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Tighten up locking around stateids in knfsd
Date: Mon, 30 Oct 2017 20:09:46 -0400
Message-Id: <20171031000951.18294-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset aims to tighten up the locking rules around stateids to
ensure that knfsd does not reuse stateids that have already been closed
or invalidated. The aim is to ensure we enforce the RFC5661 and RFC7530
rules concerning stateid initialisation and updates.

Trond Myklebust (5):
  nfsd: Fix stateid races between OPEN and CLOSE
  nfsd: CLOSE SHOULD return the invalid special stateid for NFSv4.x
    (x>0)
  nfsd: Ensure we don't recognise lock stateids after freeing them
  nfsd: Ensure we check stateid validity in the seqid operation checks
  nfsd: Fix races with check_stateid_generation()

 fs/nfsd/nfs4state.c | 128 +++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 97 insertions(+), 31 deletions(-)

-- 
2.13.6


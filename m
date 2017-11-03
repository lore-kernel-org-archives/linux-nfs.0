Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:53741 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756067AbdKCMAT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 08:00:19 -0400
Received: by mail-io0-f194.google.com with SMTP id 189so5658911iow.10
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 05:00:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/7] Tighten up locking around stateids in knfsd
Date: Fri,  3 Nov 2017 08:00:09 -0400
Message-Id: <20171103120016.6200-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset aims to tighten up the locking rules around stateids to
ensure that knfsd does not reuse stateids that have already been closed
or invalidated. The aim is to ensure we enforce the RFC5661 and RFC7530
rules concerning stateid initialisation and updates.

v2:
- Add a fix for when nfs4_get_vfs_file() fails in nfsd4_process_open2()
- Add a fix for byte range lock creation

Note that byte range locks are not completely fixed. The remaining task
of ensuring that locks don't conflict with CLOSE has been left as an
exercise for the reviewer.

Trond Myklebust (7):
  nfsd: Fix stateid races between OPEN and CLOSE
  nfsd: Fix another OPEN stateid race
  nfsd: CLOSE SHOULD return the invalid special stateid for NFSv4.x
    (x>0)
  nfsd: Ensure we don't recognise lock stateids after freeing them
  nfsd: Fix race in lock stateid creation
  nfsd: Ensure we check stateid validity in the seqid operation checks
  nfsd: Fix races with check_stateid_generation()

 fs/nfsd/nfs4state.c | 254 ++++++++++++++++++++++++++++++++++------------------
 1 file changed, 166 insertions(+), 88 deletions(-)

-- 
2.13.6


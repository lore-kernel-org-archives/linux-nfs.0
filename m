Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36366 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdF1OsD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jun 2017 10:48:03 -0400
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] Stable request to fix a reference leak and list corruption
Date: Wed, 28 Jun 2017 10:47:57 -0400
Message-Id: <20170628144758.12225-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Greg,

Could we please queue up the following patch as a stable fix for
commit a974deee47? It needs to be applied to v4.10 and older.

Thanks
  Trond

Kinglong Mee (1):
  NFSv4: fix a reference leak caused WARNING messages

 fs/nfs/nfs4proc.c | 2 --
 1 file changed, 2 deletions(-)

-- 
2.9.4


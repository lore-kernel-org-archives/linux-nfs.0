Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35946 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522Ab2FGTGn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 15:06:43 -0400
Received: by bkcji2 with SMTP id ji2so899257bkc.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jun 2012 12:06:42 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] pNFS: disable unloading a layout driver when mounted
Date: Thu,  7 Jun 2012 22:06:29 +0300
Message-Id: <1339095991-26753-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Layout drivers' refcount is incremented when a filesystem is mounted with
the layout type exported by the driver. Object layout and Block layout
drivers did not provide an owner, which means no refcount is incremented
and that the module can be unloaded while the file system is mounted
which, in turn, crashes in the layout driver when the NFS client attempts
to do something with the layout driver (typically coalescing).

Idan Kedar (2):
  pnfs-obj: disable unloading the module when mounted
  pnfsblock: disable unloading the module when mounted

 fs/nfs/blocklayout/blocklayout.c |    1 +
 fs/nfs/objlayout/objio_osd.c     |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

-- 
1.7.6.5


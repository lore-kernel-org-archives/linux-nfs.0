Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48904 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab2GWKFS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jul 2012 06:05:18 -0400
Received: by lbbgm6 with SMTP id gm6so7792703lbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jul 2012 03:05:16 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 0/3] pnfs: fix a crash when hitting Ctrl+C during LAYOUTGET
Date: Mon, 23 Jul 2012 13:05:04 +0300
Message-Id: <1343037907-26457-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While working on object layout, we have encountered a general protection fault
in xdr_shrink_bufhead when killing a process performing a lot of reads.

we reproduced it on kernel v3.3 as follows:
* mount an object-based pNFS file system. we used exofs as the MDS. assume the
mount point is /mnt/pnfs
* cp -r /bin /mnt/pnfs
* run:
cd /mnt/pnfs
while while true; do
	echo 3 > /proc/sys/vm/drop_caches; 
	rm -rf bin
	cp -r bin /tmp &
	sleep 1
	kill -s int $!
done
* on my setup it crashed after a couple of minutes, your mileage may vary.

The first patch is the actual fix. the other two are cleanups.

Idan Kedar (3):
  pnfs: defer release of pages in layoutget
  pnfs: nfs4_proc_layoutget returns void
  pnfs: use size_t for LAYOUTGET response pages count

 fs/nfs/nfs4proc.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/pnfs.c     |   39 +---------------------------------
 fs/nfs/pnfs.h     |    2 +-
 3 files changed, 60 insertions(+), 42 deletions(-)

-- 
1.7.6.5


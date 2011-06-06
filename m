Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46599 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab1FFS5g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 14:57:36 -0400
Received: by qyk7 with SMTP id 7so950041qyk.19
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jun 2011 11:57:35 -0700 (PDT)
Message-ID: <4DED231D.8070304@panasas.com>
Date: Mon, 06 Jun 2011 14:57:33 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.0-2011-06-06
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've forward ported the spnfs and spnfs-block code to 2.6.39 and 3.0.

Totally untested yet, but it compiles beautifully :)
for spnfs-block's use, I moved fallocate back to inode_operations
as a temporary solution, despite of Christoph's reservations
as this is not hitting mainline anytime soon.

respective tips are at
pnfs-all-2.6.39 pnfs-all-2.6.39-2011-06-06
pnfs-all-latest pnfs-all-3.0-2011-06-06

patches since 2011-05-31:

pnfs-all-2.6.39:
03adb44 NFS: fix umount of pnfs filesystems
f4d5c0c FIXME: spnfs cummulative patch
d6d442f SQUASHME: spnfs: use kern_path rather than path_lookup
4938a27 FIXME: spnfs-block: restore i_op->fallocate
4ce3376 FIXME: spnfs-block: pNFS block layout server implementation
cummulative patch

nfs-upstream:
cf1eb60 NFS: fix umount of pnfs filesystems

spnfs-all:
f4d5c0c FIXME: spnfs cummulative patch
d6d442f SQUASHME: spnfs: use kern_path rather than path_lookup

spnfs-block-all:
4938a27 FIXME: spnfs-block: restore i_op->fallocate
4ce3376 FIXME: spnfs-block: pNFS block layout server implementation
cummulative patch

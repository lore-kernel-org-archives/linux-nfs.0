Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34597 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbcDIOAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Apr 2016 10:00:37 -0400
Received: by mail-qg0-f54.google.com with SMTP id c6so112221649qga.1
        for <linux-nfs@vger.kernel.org>; Sat, 09 Apr 2016 07:00:37 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: don't match flexfiles mirrors that have different creds
Date: Sat,  9 Apr 2016 10:00:33 -0400
Message-Id: <1460210433-20435-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we're comparing mirrors to avoid adding duplicates to the to the
list, we must also consider the creds when comparing them. Otherwise,
mirrors that differ only by the credential will be improperly merged.

This is a problem if the client does a LAYOUTGET for a READ layout
first and then one for a RW, and the server sends a layout with a
non-usable uid for the READ layout. The RW mirror entry will get
dropped on the second layoutget as the client thinks the mirror is
identical to the one from the first. Then, when it goes to do a
WRITE, it ends up using the creds from the READ layout and the write
fails with EACCES.

Another possibility is to allow the RW segment to supersede the READ
one. The problem there is that the RW layout is returned, then the
client will still end up using the creds in the RW layout, which may
not be correct.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0cb1abd535e3..5d0789a41bc2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -172,6 +172,8 @@ ff_layout_add_mirror(struct pnfs_layout_hdr *lo,
 			continue;
 		if (!ff_mirror_match_fh(mirror, pos))
 			continue;
+		if (mirror->uid != pos->uid || mirror->gid != pos->gid)
+			continue;
 		if (atomic_inc_not_zero(&pos->ref)) {
 			spin_unlock(&inode->i_lock);
 			return pos;
-- 
2.5.5


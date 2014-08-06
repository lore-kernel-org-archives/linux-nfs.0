Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f43.google.com ([209.85.215.43]:65088 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaHFMB2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 08:01:28 -0400
From: Pavel Shilovsky <pshilovsky@samba.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@samba.org>, Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] tlock: munmap missed before close
Date: Wed,  6 Aug 2014 16:01:08 +0400
Message-Id: <1407326472-13853-2-git-send-email-pshilovsky@samba.org>
In-Reply-To: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

test13 mmaps the testfile, but doesn't munmap it before returning.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
---
 lock/tlock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lock/tlock.c b/lock/tlock.c
index 39a6ad9..6e19a3d 100644
--- a/lock/tlock.c
+++ b/lock/tlock.c
@@ -1509,6 +1509,7 @@ test13()
 			FATAL);
 		test(13, 4, F_TLOCK, (off_t)mappedlen - 2, (off_t)END,
 			lock1err, WARN);
+		testmunmap();
 		close_testfile(DO_UNLINK);
 
 		childfree(0);
-- 
1.8.1.2


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:55187 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab1HFHl2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 03:41:28 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH 2/6] nfs.man: man complains when line starts with quote
Date: Sat,  6 Aug 2011 09:41:15 +0200
Message-Id: <1312616479-312-3-git-send-email-luk@debian.org>
In-Reply-To: <1312616479-312-1-git-send-email-luk@debian.org>
References: <1312616479-312-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix "macro `local_lock=flock'.' not defined" by avoiding to put a quote at the beginning of the line.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/mount/nfs.man |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index be91a25..6152235 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -752,8 +752,8 @@ If
 is specified, the client assumes that POSIX locks are local and uses NLM
 sideband protocol to lock files when flock locks are used.
 .IP
-To support legacy flock behavior similar to that of NFS clients < 2.6.12, use
-'local_lock=flock'. This option is required when exporting NFS mounts via
+To support legacy flock behavior similar to that of NFS clients < 2.6.12, 
+use 'local_lock=flock'. This option is required when exporting NFS mounts via
 Samba as Samba maps Windows share mode locks as flock. Since NFS clients >
 2.6.12 implement flock by emulating POSIX locks, this will result in
 conflicting locks.
-- 
1.7.5.4


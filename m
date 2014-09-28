Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:65451 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaI1LQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Sep 2014 07:16:03 -0400
From: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, trivial@kernel.org
Subject: [PATCH] exportfs: Fix incorrect comment about fh_to_dentry
Date: Sun, 28 Sep 2014 20:15:59 +0900
Message-ID: <87a95k572o.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

d_alloc_root is obsolete. Replace with d_make_root.

Signed-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
---
 include/linux/exportfs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 41b223a..c668cf6 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -152,7 +152,7 @@ struct fid {
  *    it should return a %NULL pointer if the file was found but no acceptable
  *    &dentries were available, or an %ERR_PTR error code indicating why it
  *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry can be
- *    returned including, if necessary, a new dentry created with d_alloc_root.
+ *    returned including, if necessary, a new dentry created with d_make_root.
  *    The caller can then find any other extant dentries by following the
  *    d_alias links.
  *
--
1.9.3

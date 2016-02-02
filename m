Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33128 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbcBBNd3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Feb 2016 08:33:29 -0500
Received: by mail-wm0-f46.google.com with SMTP id l66so117144914wml.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Feb 2016 05:33:29 -0800 (PST)
From: Maxime Hadjinlian <maxime.hadjinlian@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Maxime Hadjinlian <maxime.hadjinlian@gmail.com>
Subject: [nfs-utils] mountd: Add check for 'struct file_handle'
Date: Tue,  2 Feb 2016 14:33:27 +0100
Message-Id: <1454420007-11486-1-git-send-email-maxime.hadjinlian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code to check if name_to_handle_at() is implemented generates only a
warning but with some toolchain it doesn't fail to link (the function must be
implemented somewhere).
However the "struct file_handle" type is not available.

So, this patch adds a check for this struct.

Signed-off-by: Maxime Hadjinlian <maxime.hadjinlian@gmail.com>
---
 configure.ac         | 1 +
 utils/mountd/cache.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 25d2ba4..a7965bd 100644
--- a/configure.ac
+++ b/configure.ac
@@ -425,6 +425,7 @@ AC_TYPE_PID_T
 AC_TYPE_SIZE_T
 AC_HEADER_TIME
 AC_STRUCT_TM
+AC_CHECK_TYPES([struct file_handle])
 
 dnl *************************************************************
 dnl Check for functions
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7847446..179ea18 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -424,7 +424,7 @@ static int same_path(char *child, char *parent, int len)
 	if (count_slashes(p) != count_slashes(parent))
 		return 0;
 
-#if HAVE_NAME_TO_HANDLE_AT
+#if defined(HAVE_NAME_TO_HANDLE_AT) && defined(HAVE_STRUCT_FILE_HANDLE)
 	struct {
 		struct file_handle fh;
 		unsigned char handle[128];
-- 
2.7.0


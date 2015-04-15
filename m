Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34837 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295AbbDOQUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2015 12:20:54 -0400
Received: by pdbqd1 with SMTP id qd1so57723610pdb.2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2015 09:20:54 -0700 (PDT)
Message-ID: <552E8FDF.8020104@gmail.com>
Date: Thu, 16 Apr 2015 00:20:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, kinglongmee@gmail.com
Subject: [PATCH 2/3] configure.ac: fix configure fail with --disable-mount
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Configure fail as,
# ./configure --disable-mount
... ...
checking for suitable libblkid version... yes
checking for mnt_context_do_mount in -lmount... no
configure: error: libmount needed

It is caused by $enable_libmount is "" (not "yes" and "no")
with --disable-mount.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 21be2bd..d4301a2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -346,7 +346,7 @@ AC_SUBST(LIBBSD)
 AC_SUBST(LIBBLKID)
 AC_SUBST(LIBDL)
 
-if test "$enable_libmount" != no; then
+if test "$enable_libmount" == yes; then
    AC_CHECK_LIB(mount, mnt_context_do_mount, [LIBMOUNT="-lmount"], AC_MSG_ERROR([libmount needed]))
    AC_CHECK_HEADER(libmount/libmount.h, , AC_MSG_ERROR([Cannot find libmount header file libmount/libmount.h]))
 fi
-- 
2.3.5


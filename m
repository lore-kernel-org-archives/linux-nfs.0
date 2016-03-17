Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:48156 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932909AbcCQLdY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 07:33:24 -0400
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id DEFEE47E04C
	for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2016 12:20:34 +0100 (CET)
Date: Thu, 17 Mar 2016 14:13:07 +0300
From: Alexey Dvoichenkov <xale@hyperplane.net>
To: linux-nfs@vger.kernel.org
Cc: spender@grsecurity.net
Subject: nfs_super_set_maxbytes patch
Message-Id: <20160317141307.531709bf667a915973060eae@hyperplane.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello. I've found a small bug in what appears to be the maximum file
size handling code.

The problem here, as far as I understand, is that casting from an
unsigned type to a signed type, when the latter cannot represent the
arithmetic value of the former, is UB. In practice, under the PaX size
overflow protection, this code crashes when mounting from FreeBSD
servers that send "all ones" in the size field.

Not sure I'm doing things right with the list and I'm not subscribed, so
please CC.

The fix should look something like this:

--- fs/nfs/internal.h.orig	2015-11-02 10:05:25.000000000 +1000
+++ fs/nfs/internal.h	2016-01-02 03:19:04.599120855 +1000
@@ -612,9 +612,9 @@
 static inline
 void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
 {
+	if (maxfilesize > MAX_LFS_FILESIZE || maxfilesize == 0)
+		maxfilesize = MAX_LFS_FILESIZE;
 	sb->s_maxbytes = (loff_t)maxfilesize;
-	if (sb->s_maxbytes > MAX_LFS_FILESIZE || sb->s_maxbytes <= 0)
-		sb->s_maxbytes = MAX_LFS_FILESIZE;
 }
 
 /*


-- AD

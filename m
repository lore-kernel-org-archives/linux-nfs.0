Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:33334 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753179Ab0KIUjv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Nov 2010 15:39:51 -0500
Date: Tue, 9 Nov 2010 15:39:49 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] nfs-utils: Remove blkmapd config file, which is no longer
 used.
Message-ID: <20101109203949.GA8466@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/etc/blkmapd.conf |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)
 delete mode 100644 utils/blkmapd/etc/blkmapd.conf

diff --git a/utils/blkmapd/etc/blkmapd.conf b/utils/blkmapd/etc/blkmapd.conf
deleted file mode 100644
index da70d94..0000000
--- a/utils/blkmapd/etc/blkmapd.conf
+++ /dev/null
@@ -1,10 +0,0 @@
-# This is an example config file
-
-# Look at all /dev/sd* devices
-# /dev/sd or /dev/sd*
-/dev/sd*
-
-# Look at all /dev/mapper/* devices
-# /dev/mapper/* or
-# /dev/mapper/
-/dev/mapper/*
-- 
1.7.1


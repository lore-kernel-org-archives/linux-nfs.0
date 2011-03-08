Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:63042 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891Ab1CHXLo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2011 18:11:44 -0500
Received: by qyk7 with SMTP id 7so3338871qyk.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Mar 2011 15:11:43 -0800 (PST)
From: Huang Weiyi <weiyi.huang@gmail.com>
To: neilb@suse.de
Cc: linux-nfs@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 3/3] nfs4: remove duplicated #include
Date: Wed,  9 Mar 2011 07:11:30 +0800
Message-Id: <1299625890-6136-1-git-send-email-weiyi.huang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove duplicated #include('s) in
  fs/nfs/nfs4proc.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 fs/nfs/nfs4proc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ff76ac..7f53c52 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -51,7 +51,6 @@
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
-#include <linux/mm.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
-- 
1.6.1.3


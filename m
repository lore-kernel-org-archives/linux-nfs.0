Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:38115 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbcDQJLJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:11:09 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 41DB420A84
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:11:02 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:10:23 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] svc_raw.c: Include <string.h> for memset
Message-ID: <20160417091023.GC2737@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/svc_raw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/svc_raw.c b/src/svc_raw.c
index a8a396f..0eb0965 100644
--- a/src/svc_raw.c
+++ b/src/svc_raw.c
@@ -43,6 +43,7 @@
 #include <sys/types.h>
 #include <rpc/raw.h>
 #include <stdlib.h>
+#include <string.h>
 
 #ifndef UDPMSGSIZE
 #define	UDPMSGSIZE 8800
-- 
2.7.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:59714 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932741AbcDSRhz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Apr 2016 13:37:55 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id CF4CF20A69
	for <linux-nfs@vger.kernel.org>; Tue, 19 Apr 2016 19:37:52 +0200 (CEST)
Received: from mail.posteo.de (localhost [127.0.0.1])
	by dovecot03.posteo.de (Postfix) with ESMTPSA id 3qqC0052pxz5vMr
	for <linux-nfs@vger.kernel.org>; Tue, 19 Apr 2016 19:37:52 +0200 (CEST)
Date: Tue, 19 Apr 2016 19:37:12 +0200
From: Felix Janda <felix.janda@posteo.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH libnfsidmap 2/2] cfg.c: include <sys/types.h> for u_char and
 u_int*_t
Message-ID: <20160419173712.GB20307@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 cfg.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/cfg.c b/cfg.c
index bd7944a..3c86c84 100644
--- a/cfg.c
+++ b/cfg.c
@@ -34,6 +34,7 @@
 #include <sys/mman.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
+#include <sys/types.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <ctype.h>
-- 
2.7.3

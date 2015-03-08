Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx02.posteo.de ([89.146.194.165]:60011 "EHLO mx02.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751963AbbCHLnK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Mar 2015 07:43:10 -0400
Received: from dovecot03.posteo.de (unknown [185.67.36.28])
	by mx02.posteo.de (Postfix) with ESMTPS id 0979B25A3DF2
	for <linux-nfs@vger.kernel.org>; Sun,  8 Mar 2015 12:43:08 +0100 (CET)
Received: from mail.posteo.de (localhost [127.0.0.1])
	by dovecot03.posteo.de (Postfix) with ESMTPSA id 3l0LR04dCfz5vN4
	for <linux-nfs@vger.kernel.org>; Sun,  8 Mar 2015 12:43:08 +0100 (CET)
Date: Sun, 8 Mar 2015 12:39:31 +0100
From: Felix Janda <felix.janda@posteo.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH libnfsidmap] cfg.h: Include <sys/types.h> for u_int*_t
Message-ID: <20150308113931.GA9713@euler>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
It would also be nice to iconv -f iso-8859-1

 cfg.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/cfg.h b/cfg.h
index d4d4cab..fe49e8f 100644
--- a/cfg.h
+++ b/cfg.h
@@ -33,6 +33,7 @@
 #ifndef _CONF_H_
 #define _CONF_H_
 
+#include <sys/types.h>
 #include "queue.h"
 
 struct conf_list_node {
-- 
2.0.5

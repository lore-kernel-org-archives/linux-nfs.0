Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:52436 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209AbcDSRgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Apr 2016 13:36:01 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 343032084C
	for <linux-nfs@vger.kernel.org>; Tue, 19 Apr 2016 19:35:58 +0200 (CEST)
Received: from mail.posteo.de (localhost [127.0.0.1])
	by dovecot03.posteo.de (Postfix) with ESMTPSA id 3qqBxn73Zxz5vN5
	for <linux-nfs@vger.kernel.org>; Tue, 19 Apr 2016 19:35:57 +0200 (CEST)
Date: Tue, 19 Apr 2016 19:35:17 +0200
From: Felix Janda <felix.janda@posteo.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH libnfsidmap 1/2] cfg.*: iconv to utf8
Message-ID: <20160419173517.GA20307@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 cfg.c | 2 +-
 cfg.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/cfg.c b/cfg.c
index e0ab839..bd7944a 100644
--- a/cfg.c
+++ b/cfg.c
@@ -3,7 +3,7 @@
 
 /*
  * Copyright (c) 1998, 1999, 2000, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2001, 2002 Håkan Olsson.  All rights reserved.
+ * Copyright (c) 2000, 2001, 2002 HÃ¥kan Olsson.  All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
diff --git a/cfg.h b/cfg.h
index d4d4cab..80ddfd6 100644
--- a/cfg.h
+++ b/cfg.h
@@ -3,7 +3,7 @@
 
 /*
  * Copyright (c) 1998, 1999, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2003 Håkan Olsson.  All rights reserved.
+ * Copyright (c) 2000, 2003 HÃ¥kan Olsson.  All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
-- 
2.7.3


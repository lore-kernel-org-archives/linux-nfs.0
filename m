Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:43161 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbcDQJM7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:12:59 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id D4E0B20A0D
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:12:57 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:12:19 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] Delete unused epoll_sub.c
Message-ID: <20160417091219.GA3299@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/epoll_sub.c | 58 ---------------------------------------------------------
 1 file changed, 58 deletions(-)
 delete mode 100644 src/epoll_sub.c

diff --git a/src/epoll_sub.c b/src/epoll_sub.c
deleted file mode 100644
index 16583ba..0000000
--- a/src/epoll_sub.c
+++ /dev/null
@@ -1,58 +0,0 @@
-/*
- * Copyright 2003 Niels Provos <provos@citi.umich.edu>
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. The name of the author may not be used to endorse or promote products
- *    derived from this software without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-#include <stdint.h>
-
-#include <sys/param.h>
-#include <sys/types.h>
-#include <sys/syscall.h>
-#include <sys/epoll.h>
-#include <unistd.h>
-
-
-/*Paramètres du syscall - Attention spécifique hardware */
-#define __NR_epoll_create 254
-#define __NR_epoll_ctl	255
-#define __NR_epoll_wait	256
-
-int
-epoll_create(int size)
-{
-	return (syscall(__NR_epoll_create, size));
-}
-
-int
-epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)
-{
-
-	return (syscall(__NR_epoll_ctl, epfd, op, fd, event));
-}
-
-int
-epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout)
-{
-	return (syscall(__NR_epoll_wait, epfd, events, maxevents, timeout));
-}
-- 
2.7.3


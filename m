Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:42359 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754639Ab0JEUeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 16:34:09 -0400
Date: Tue, 5 Oct 2010 16:34:00 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] fix style nits in atomicio.c
Message-ID: <20101005203400.GA16030@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 support/nfs/atomicio.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/support/nfs/atomicio.c b/support/nfs/atomicio.c
index 1fb1ff9..8db626e 100644
--- a/support/nfs/atomicio.c
+++ b/support/nfs/atomicio.c
@@ -28,23 +28,13 @@
 #include <unistd.h>
 #include <errno.h>
 
-#ifdef HAVE_CONFIG_H
-#include "config.h"
-#endif /* HAVE_CONFIG_H */
-
 /*
  * ensure all of data on socket comes through. f==read || f==write
  */
-ssize_t
-atomicio(
-	ssize_t (*f) (int, void*, size_t),
-	int fd,
-	void *_s,
-	size_t n)
+ssize_t atomicio(ssize_t(*f) (int, void *, size_t), int fd, void *_s, size_t n)
 {
 	char *s = _s;
-	ssize_t res;
-	size_t pos = 0;
+	ssize_t res, pos = 0;
 
 	while (n > pos) {
 		res = (f) (fd, s + pos, n - pos);
@@ -54,11 +44,11 @@ atomicio(
 				continue;
 		case 0:
 			if (pos != 0)
-				return (pos);
-			return (res);
+				return pos;
+			return res;
 		default:
 			pos += res;
 		}
 	}
-	return (pos);
+	return pos;
 }
-- 
1.7.0.4


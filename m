Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752016AbeDJVaq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 17:30:46 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Restore creating listening connection to server connections
Date: Tue, 10 Apr 2018 17:30:43 -0400
Message-Id: <20180410213043.5545-2-steved@redhat.com>
In-Reply-To: <20180410213043.5545-1-steved@redhat.com>
References: <20180410213043.5545-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 46e04a73 changed svc_com_create() to avoid using
reserve ports but removed the listen() call which
could break, undocumented expectations, of legacy
server apps.

Reserve ports are not needed for listening ports, so
the new  __binddynport() is used to avoid squatting
on ports that are assigned to other network services,
but it is important to say backwards compatible
with the legacy glibc code so the the listen()
call is added back.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpc_soc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index f32a27c..cf15216 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -331,6 +331,13 @@ svc_com_create(fd, sendsize, recvsize, netid)
 		madefd = TRUE;
 	}
 
+	if (__binddynport(fd) == -1) {
+		if (madefd)
+			(void)close(fd);
+		(void) syslog(LOG_ERR,
+			"svc%s_create: could not bind connection: %m", netid);
+	}
+	listen(fd, SOMAXCONN);
 	svc = svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
 	(void) freenetconfigent(nconf);
 	if (svc == NULL) {
-- 
2.14.3


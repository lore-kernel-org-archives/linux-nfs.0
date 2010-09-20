Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59639 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab0ITQc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:32:57 -0400
Received: by gyd8 with SMTP id 8so1351673gyd.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:32:57 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] mountd: Unregister mountd if my_svc_run() returns
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:32:54 -0400
Message-ID: <20100920163254.3170.30786.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fix a long standing bug: when my_svc_run() returns, mountd should
unregister itself with the local rpcbind so that it can subsequently
start cleanly.

Log a more helpful error message in this case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index a4fdcc8..9c7caf9 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -888,7 +888,8 @@ main(int argc, char **argv)
 
 	my_svc_run();
 
-	xlog(L_ERROR, "Ack! Gack! svc_run returned!\n");
+	xlog(L_ERROR, "RPC service loop terminated unexpectedly. Exiting...\n");
+	unregister_services();
 	exit(1);
 }
 


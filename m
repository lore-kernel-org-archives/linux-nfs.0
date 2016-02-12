Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:50916 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbcBLGpL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 01:45:11 -0500
From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH nfs-utils] statd: Don't unregister statd service on failing to execute callout
Date: Fri, 12 Feb 2016 15:41:22 +0900
Message-Id: <1455259282-7237-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
To: Steve Dickson <steved@redhat.com>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

statd calls atexit(statd_unregister) to unregister statd service on exit,
which actually has a side-effect that ha_callout() unregisters statd
service even when the child callout process exits on execl() failure.

Certain clustering software's deployment script adds -H option with its
specified file non-existent, when it is configured not to use callout.
In other words, -H seems to be used no matter if callout is needed or not,
but when callout is unnecessary, the specified callout program is not
deployed.
This causes statd not to work once a lock is requested by its NFS client,
as execl() in ha_callout() results in ENOENT and exit() of the child
process calls exit-handler statd_unregister(). Eventually, the NFS client
gets stuck with messages "lockd: cannot monitor xxx" on the NFS server.

Although this may not be an expected way of using -H option, it would be
better if statd could continue to work even in that situation. Also,
execl() could fail for other reasons like ENFILE and EIO, where statd
service should not be unregistered as well.
Call _exit(), which does not call any exit-handlers, instead of exit() to
take care of those situations and make statd more reliable.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 support/include/ha-callout.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/include/ha-callout.h b/support/include/ha-callout.h
index 1164336..a454bdb 100644
--- a/support/include/ha-callout.h
+++ b/support/include/ha-callout.h
@@ -47,7 +47,7 @@ ha_callout(char *event, char *arg1, char *arg2, int arg3)
 			      arg3 < 0 ? NULL : buf,
 			      NULL);
 			perror("execl");
-			exit(2);
+			_exit(2);
 		case -1: perror("fork");
 			break;
 		default: pid = waitpid(pid, &ret, 0);
-- 
1.7.1




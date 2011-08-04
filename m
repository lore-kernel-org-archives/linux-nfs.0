Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754411Ab1HECTI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 22:19:08 -0400
From: Max Matveev <makc@redhat.com>
Date: Thu, 4 Aug 2011 15:47:33 +1000
Subject: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, rees@umich.edu
Message-Id: <20110805021903.C84608198734@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFS/TCP does linear backoff then retransmiting - the manpage
was mistakenly asserting the "no backoff" theory.

Signed-off-by: Max Matveev <makc@redhat.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/mount/nfs.man |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index be91a25..ff0ed60 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -113,12 +113,16 @@ option may mitigate some of the risks of using the
 option.
 .TP 1.5i
 .BI timeo= n
-The time (in tenths of a second) the NFS client waits for a
-response before it retries an NFS request. If this
-option is not specified, requests are retried every
-60 seconds for NFS over TCP.
-The NFS client does not perform any kind of timeout backoff
-for NFS over TCP.
+The time in deciseconds (tenths of a second) the NFS client waits for a
+response before it retries an NFS request.
+.IP
+For NFS over TCP the default
+.B timeo
+value is 600 (60 seconds).
+The NFS client performs linear backoff: After each retransmission the 
+timeout is increased by
+.BR timeo 
+up to the maximum of 600 seconds.
 .IP
 However, for NFS over UDP, the client uses an adaptive
 algorithm to estimate an appropriate timeout value for frequently used
-- 
1.7.4.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951Ab1HDG3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 02:29:01 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p746T12J025982
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 4 Aug 2011 02:29:01 -0400
In-Reply-To: <20026.13331.411712.805796@regina.usersys.redhat.com>
References: <20026.13331.411712.805796@regina.usersys.redhat.com>
From: Max Matveev <makc@redhat.com>
Date: Thu, 4 Aug 2011 15:47:33 +1000
Subject: [PATCH] Update nfs(5) manpage - timeo for NFS/TCP
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Message-Id: <20110804062858.EAD96813270B@regina.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFS/TCP does linear backoff then retransmiting - the manpage
was mistakenly asserting the "no backoff" theory.

Signed-off-by: Max Matveev <makc@redhat.com>
---
 utils/mount/nfs.man |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index be91a25..7681b10 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -114,11 +114,15 @@ option.
 .TP 1.5i
 .BI timeo= n
 The time (in tenths of a second) the NFS client waits for a
-response before it retries an NFS request. If this
-option is not specified, requests are retried every
-60 seconds for NFS over TCP.
-The NFS client does not perform any kind of timeout backoff
-for NFS over TCP.
+response before it retries an NFS request.
+.IP
+For NFS over TCP the default
+.B timeo
+value is 600 which equals to 60 seconds.
+The NFS client performs linear backoff  -
+after each retransmission the timeout is increased by
+.BR timeo /10
+seconds upto the maximum of 600 seconds.
 .IP
 However, for NFS over UDP, the client uses an adaptive
 algorithm to estimate an appropriate timeout value for frequently used
-- 
1.7.4.4


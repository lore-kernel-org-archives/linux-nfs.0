Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755000AbcFQBul (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2016 21:50:41 -0400
From: yongcheng.yang@gmail.com
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, yoyang@redhat.com,
        Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] nfsdcltrack: fix a typo in the manpage
Date: Fri, 17 Jun 2016 09:50:22 +0800
Message-Id: <1466128222-21415-1-git-send-email-yongcheng.yang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yongcheng.yang@gmail.com>

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---
 utils/nfsdcltrack/nfsdcltrack.man | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsdcltrack/nfsdcltrack.man b/utils/nfsdcltrack/nfsdcltrack.man
index c37c9a8..4b8f4d7 100644
--- a/utils/nfsdcltrack/nfsdcltrack.man
+++ b/utils/nfsdcltrack/nfsdcltrack.man
@@ -22,7 +22,7 @@ nfsdcltrack \- NFSv4 Client Tracking Callout Program
 nfsdcltrack [\-d] [\-f] [\-s stable storage dir] <command> <args...>
 .SH "DESCRIPTION"
 .IX Header "DESCRIPTION"
-nfsdcltack is the NFSv4 client tracking callout program. It is not necessary
+nfsdcltrack is the NFSv4 client tracking callout program. It is not necessary
 to install this program on machines that are not acting as NFSv4 servers.
 .PP
 When a network partition is combined with a server reboot, there are
-- 
2.4.3


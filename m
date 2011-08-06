Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:38352 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab1HFHla (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 03:41:30 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH 3/6] statd.man: man complains about lines starting with '
Date: Sat,  6 Aug 2011 09:41:16 +0200
Message-Id: <1312616479-312-4-git-send-email-luk@debian.org>
In-Reply-To: <1312616479-312-1-git-send-email-luk@debian.org>
References: <1312616479-312-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix syntax for line starting with 'visible' according to a patch from Simon Paillard <spaillard@debian.org> in Debian bug #624261.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/statd/statd.man |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index 203f8c9..c3c5354 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -350,8 +350,7 @@ of the requesting lock manager.
 TI-RPC is a pre-requisite for supporting NFS on IPv6.
 If TI-RPC support is built into
 .BR rpc.statd ,
-it attempts to start listeners on network transports marked
-'visible' in
+it attempts to start listeners on network transports marked 'visible' in
 .IR /etc/netconfig .
 As long as at least one network transport listener starts successfully,
 .B rpc.statd
-- 
1.7.5.4


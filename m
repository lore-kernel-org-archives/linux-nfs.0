From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] set +x on t0001-statd-basic-mon-unmon.sh
Date: Sun, 11 Apr 2010 17:51:25 -0400
Message-ID: <1271022685-27800-1-git-send-email-vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:34229 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753073Ab0DKVv6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Apr 2010 17:51:58 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 786B21B404F
	for <linux-nfs@vger.kernel.org>; Sun, 11 Apr 2010 21:51:57 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The test framework tries to exec this script, but it fails because it
lacks the +x bit.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 0 files changed, 0 insertions(+), 0 deletions(-)
 mode change 100644 => 100755 tests/t0001-statd-basic-mon-unmon.sh

diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001-statd-basic-mon-unmon.sh
old mode 100644
new mode 100755
-- 
1.7.0.2


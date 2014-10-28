Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbaJ1NQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 09:16:59 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH 4/4] generic/277: add _require_attrs
Date: Tue, 28 Oct 2014 21:16:11 +0800
Message-Id: <1414502171-10319-5-git-send-email-eguan@redhat.com>
In-Reply-To: <1414502171-10319-1-git-send-email-eguan@redhat.com>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS doesn't support attr yet, add _require_attrs in generic/277 to avoid
failure when testing on NFS.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 tests/generic/277 | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tests/generic/277 b/tests/generic/277
index 8461ad9..39ebdc3 100755
--- a/tests/generic/277
+++ b/tests/generic/277
@@ -38,11 +38,13 @@ trap "_cleanup ; exit \$status" 0 1 2 3 15
 # get standard environment, filters and checks
 . ./common/rc
 . ./common/filter
+. ./common/attr
 
 # real QA test starts here
 _supported_fs generic
 _supported_os Linux
 _require_scratch
+_require_attrs
 
 _scratch_mkfs > /dev/null 2>&1
 _scratch_mount
-- 
1.8.3.1


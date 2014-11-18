Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbaKROGq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:46 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6j9M030579
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6ipm014035
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] mount.nfs: fix a comment typo in parse options
Date: Tue, 18 Nov 2014 09:06:40 -0500
Message-Id: <22d8bd4b7aed22f2664da4ffb2874b160bcdf1ce.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/parse_opt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index 75a0daa..342e210 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -391,7 +391,7 @@ po_return_t po_append(struct mount_options *options, char *str)
 }
 
 /**
- * po_contains - check for presense of an option in a group
+ * po_contains - check for presence of an option in a group
  * @options: pointer to mount options
  * @keyword: pointer to a C string containing option keyword for which to search
  *
-- 
1.7.1


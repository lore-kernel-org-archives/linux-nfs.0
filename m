From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/2] Cleared up the sync option in the exportfs man page
Date: Tue, 19 Oct 2010 16:00:24 -0400
Message-ID: <1287518425-12962-2-git-send-email-steved@redhat.com>
References: <1287518425-12962-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606Ab0JST4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Oct 2010 15:56:07 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o9JJu7Bq022842
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 15:56:07 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o9JJu6hK028627
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 15:56:07 -0400
In-Reply-To: <1287518425-12962-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/exportfs/exports.man |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index bfc4d42..4e3edc5 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -145,7 +145,9 @@ storage (see
 .IR async
 above).
 
-In releases of nfs-utils up to and including 1.0.0, this option was the
+In releases of nfs-utils up to and including 1.0.0, the
+.I async 
+option was the
 default.  In all releases after 1.0.0,
 .I sync
 is the default, and
-- 
1.7.2.3


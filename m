Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab1AZM5j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jan 2011 07:57:39 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0QCvcs9025949
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jan 2011 07:57:39 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p0QCvccb030277
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jan 2011 07:57:38 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Fixed segfault in rpc.mountd
Date: Wed, 26 Jan 2011 07:57:35 -0500
Message-Id: <1296046655-20246-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A unallocated piece of memory, instead of a NULL point, was being
used to initialize a ->next point in the mount link list which
caused a segfault after a few remote accesses via the showmount
command.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/rmtab.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index d339296..527377f 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -205,6 +205,7 @@ mountlist_list(void)
 	}
 	if (stb.st_mtime != last_mtime) {
 		mountlist_freeall(mlist);
+		mlist = NULL;
 		last_mtime = stb.st_mtime;
 
 		setrmtabent("r");
-- 
1.7.3.3


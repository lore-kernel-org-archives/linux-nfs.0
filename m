Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56198 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751508AbdHGTJH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Aug 2017 15:09:07 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 08A6E37E67
        for <linux-nfs@vger.kernel.org>; Mon,  7 Aug 2017 19:09:07 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] idmapd: fix object order in idmapd_LDADD
Date: Mon,  7 Aug 2017 15:09:06 -0400
Message-Id: <20170807190906.7360-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs-utils and libnfsidmap have similar configuration parsing routines.
They were the same up until nfs-utils commit 7b33590f (config: Remove
the conf_path global), where conf_init() was changed to take a path as
an argument.  With the current idmap_LDADD ordering in Makefile.am, the
conf_init() from libnfsidmap is called, resulting in the following error
along with the failure to parse idmapd.conf:

rpc.idmapd[391]: rpc.idmapd: conf_reinit: open ("(null)", O_RDONLY) failed

Placing libnfs.a first in idmap_LDADD ensures that idmapd uses the config
parsing routines from nfs-utils instead of libnfsidmap.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/idmapd/Makefile.am | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index c2f8ba1..1e8e9e6 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -15,7 +15,7 @@ idmapd_SOURCES = \
 	nfs_idmap.h \
 	queue.h
 
-idmapd_LDADD = $(LIBEVENT) $(LIBNFSIDMAP) ../../support/nfs/libnfs.a
+idmapd_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBNFSIDMAP)
 
 MAINTAINERCLEANFILES = Makefile.in
 
-- 
2.9.4


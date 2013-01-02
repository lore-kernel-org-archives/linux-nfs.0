Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233Ab3ABSvg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 13:51:36 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r02Ipat5029322
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 2 Jan 2013 13:51:36 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r02IpZUA004948
	for <linux-nfs@vger.kernel.org>; Wed, 2 Jan 2013 13:51:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.idmapd: Ignore open failures in dirscancb()
Date: Wed,  2 Jan 2013 13:47:53 -0500
Message-Id: <1357152473-4260-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Jeffery <djeffery@redhat.com>

The daemon "rpc.idmapd" scans the /var/lib/nfs/rpc_pipefs/nfs/ directory
periodically looking for NFS client mounts to communicate to. The daemon
tried to open communication with a client mount but it disappeared in
between looking for directory entries and opening them. NFS mount was
umounted just before rpc.idmapd tried to communicate with it. This
behavior is usually seen when autofs is configured on the system.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 9d66225..beba9c4 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -424,7 +424,8 @@ dirscancb(int UNUSED(fd), short UNUSED(which), void *data)
 			    pipefsdir, ents[i]->d_name);
 
 			if ((ic->ic_dirfd = open(path, O_RDONLY, 0)) == -1) {
-				xlog_warn("dirscancb: open(%s): %s", path, strerror(errno));
+				if (verbose > 0)
+					xlog_warn("dirscancb: open(%s): %s", path, strerror(errno));
 				free(ic);
 				goto out;
 			}
-- 
1.7.11.7


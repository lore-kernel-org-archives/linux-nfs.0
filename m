From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] umount.nfs: Use a privileged port when sending UMNT
	requests
Date: Fri, 17 Apr 2009 16:17:49 -0400
Message-ID: <20090417201749.14555.21530.stgit@ingres.1015granger.net>
References: <20090417201021.14555.93852.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet02.oracle.com ([141.146.126.229]:16655 "EHLO
	agminet02.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbZDQVHs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 17:07:48 -0400
In-Reply-To: <20090417201021.14555.93852.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turns out we do actually need to use a privileged port for UMNT.  The
Linux rpc.mountd complains if an ephemeral source port is used:

  Apr 17 15:52:19 ingres mountd[2061]: refused unmount request from
    192.168.0.59 for /export (/export): illegal port 60932

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index bcd0c0f..234e7f3 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -869,7 +869,7 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 	memcpy(saddr, sap, salen);
 	nfs_set_port(saddr, mnt_pmap.pm_port);
 
-	client = nfs_get_rpcclient(saddr, salen, mnt_pmap.pm_prot,
+	client = nfs_get_priv_rpcclient(saddr, salen, mnt_pmap.pm_prot,
 					mnt_pmap.pm_prog, mnt_pmap.pm_vers,
 					&timeout);
 	if (client == NULL)


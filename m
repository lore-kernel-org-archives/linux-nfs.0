From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] umount.nfs: Skip UMNT call for "-t nfs -o vers=4" mounts
Date: Tue, 08 Sep 2009 17:02:58 -0400
Message-ID: <20090908210258.3326.56972.stgit@matisse.1015granger.net>
References: <20090908210012.3326.57767.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:22681 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbZIHVE1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 17:04:27 -0400
In-Reply-To: <20090908210012.3326.57767.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index f81db14..c5505b1 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -179,6 +179,10 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 		return EX_FAIL;
 	}
 
+	/* Skip UMNT call for vers=4 mounts */
+	if (nfs_pmap.pm_vers == 4)
+		return EX_SUCCESS;
+
 	*hostname = nfs_umount_hostname(options, *hostname);
 	if (!*hostname) {
 		nfs_error(_("%s: out of memory"), progname);


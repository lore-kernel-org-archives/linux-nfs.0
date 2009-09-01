From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] umount.nfs: Skip UMNT call for "-t nfs -o vers=4" mounts
Date: Tue, 01 Sep 2009 10:29:08 -0400
Message-ID: <20090901142907.3886.56927.stgit@matisse.1015granger.net>
References: <20090901142357.3886.21465.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:58242 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914AbZIAO3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:29:30 -0400
In-Reply-To: <20090901142357.3886.21465.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make umount.nfs skip the UMNT call for vers=4 mounts, since NFSv4
doesn't need it.

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


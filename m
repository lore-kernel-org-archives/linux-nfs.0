From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/11] NFS: Revert default r/wsize behavior
Date: Thu, 05 Nov 2009 13:22:50 -0500
Message-ID: <20091105182249.2796.14567.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:37604
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758052AbZKESWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:22:52 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the "rsize=" or "wsize=" mount options are not specified,
text-based mounts have slightly different behavior than legacy binary
mounts.  Text-based mounts use the smaller of the server's maximum
and the client's maximum, but binary mounts use the smaller of the
server's _preferred_ size and the client's maximum.

This difference is actually pretty subtle.  Most servers advertise
the same value as their maximum and their preferred transfer size, so
the end result is the same in most cases.

The reason for this difference is that for text-based mounts, if
r/wsize are not specified, they are set to the largest value supported
by the client.  For legacy mounts, the values are set to zero if these
options are not specified.

nfs_server_set_fsinfo() can negotiate the transfer size defaults
correctly in any case.  There's no need to specify any particular
value as default in the text-based option parsing logic.

Note that nfs4 doesn't use nfs_server_set_fsinfo(), but the mount.nfs4
command does set rsize and wsize to 0 if the user didn't specify these
options.  So, make the same change for text-based NFSv4 mounts.

Thanks to James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org> for reporting and
diagnosing the problem.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 968c7ac..7eaa41e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -734,8 +734,6 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data) {
-		data->rsize		= NFS_MAX_FILE_IO_SIZE;
-		data->wsize		= NFS_MAX_FILE_IO_SIZE;
 		data->acregmin		= NFS_DEF_ACREGMIN;
 		data->acregmax		= NFS_DEF_ACREGMAX;
 		data->acdirmin		= NFS_DEF_ACDIRMIN;


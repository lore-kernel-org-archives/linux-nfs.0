From: NeilBrown <neilb@suse.de>
Subject: [PATCH 2/2] NFS: honour preferred rsize/wsize reported by server.
Date: Tue, 17 Nov 2009 15:21:24 +1100
Message-ID: <20091117042124.1563.32006.stgit@notabene.brown>
References: <20091117042004.1563.95871.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46284 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbZKQEVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 23:21:31 -0500
In-Reply-To: <20091117042004.1563.95871.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a filesystem is mounted with ASCII mount options, and no rsize
or wsize is given, the client should default to using the preferred
sizes reported in the FSINFO request.
However it does not.  These values are initialised to
NFS_MAX_FILE_IO_SIZE and as they are now non-zero, the default does
not get applied.

So initialise to 0 thus allowing appropriate defaults to apply.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfs/super.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 90be551..18c5f85 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -734,8 +734,8 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data) {
-		data->rsize		= NFS_MAX_FILE_IO_SIZE;
-		data->wsize		= NFS_MAX_FILE_IO_SIZE;
+		data->rsize		= 0;
+		data->wsize		= 0;
 		data->acregmin		= NFS_DEF_ACREGMIN;
 		data->acregmax		= NFS_DEF_ACREGMAX;
 		data->acdirmin		= NFS_DEF_ACDIRMIN;



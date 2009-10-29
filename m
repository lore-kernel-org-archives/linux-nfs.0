From: Neil Brown <neilb@suse.de>
Subject: [PATCH] NFS client ignores server preferred IO size when
   'ascii' mount options used.
Date: Thu, 29 Oct 2009 21:14:49 +1100
Message-ID: <19177.27417.641206.213064@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41230 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753872AbZJ2KNY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Oct 2009 06:13:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond et al,

 I just had a report from a customer that NFS (SLES11) was ignoring
 the rsize/wsize set by the server.

 A quick inspection of the code (in current upstream) shows that this
 is indeed the case.

 nfs_get_sb calls nfs_alloc_parsed_mount_data which set rsize and
 wsize in 'data' to NFS_MAX_FILE_IO_SIZE (which is not zero).

 It then calls nfs_validate_mount_data which will over-write this
 valid if 'binary' mount options are in use, but with ascii mount
 options, the values will only be changed in rsize and/or wsize is
 explicitly listed.

 So in the common case of ascii mount options and no rsize/wsize,
 they remain at NFS_MAX_FILE_IO_SIZE.

 Then nfs_get_sb calls nfs_create_server which calls
 nfs_init_server which copies the rsize and rsize (being non-zero)
 across from 'data' to 'server' (clipping to
 NFS_{MIN,MAX}_FILE_IO_SIZE).

 Then nfs_create_server calls nfs_probe_fsinfo which calls
 nfs_server_set_fsinfo which sets ->rsize to fsinfo->rtpref
 only if ->rsize is zero.  But it isn't, it is NFS_MAX_FILE_IO_SIZE.
 So the ->rtpref and ->wtpref are ignored when they should be used.

 I suspect the required patch will be something like the following
 though I haven't tested it yet (it is late:-).
 There should probably be a comment in there pointing out that these
 values get their defaults from fsinfo.
 I also have only looked at the v3 path, not the v4 path.

 But I thought I'd let you know promptly as I'm not sure when I'll get
 around to proper testing.

NeilBrown


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

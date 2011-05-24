Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36963 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab1EXK4m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 06:56:42 -0400
Message-ID: <4DDB8ED0.9000506@panasas.com>
Date: Tue, 24 May 2011 13:56:16 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] SQUASHME: pnfs-obj: objlayout wants to cache devices
 until unmount
References: <4DDB8DD1.20101@panasas.com>
In-Reply-To: <4DDB8DD1.20101@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Take an extra reference on a device insert. So devices keep
around in the cache until nfs_client release.
(This was the behaviour of the old cache)

The extra reference will be removed in nfs4_deviceid_purge_client().
I tested this and it works perfectly.

TODO: Define an nfs4_get_deviceid()
 Currently accessing did->ref directly

TODO: nfs4_insert_deviceid_node should check if there are too many
      devices and start purging them. Say by longest time from last use.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index c09066f..47e8cb5 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -110,6 +110,7 @@ _dev_list_add(const struct nfs_server *nfss,
 		de = n;
 	}
 
+	atomic_inc(&de->id_node.ref);
 	return de;
 }
 
-- 
1.7.2.3



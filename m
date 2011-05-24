Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46750 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346Ab1EXPHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:07:11 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/12] SQUASHME: pnfs-obj: use layout driver in global device cache
Date: Tue, 24 May 2011 18:06:39 +0300
Message-Id: <1306249599-23362-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

This is the objio_osd part of the patch:
	NFSv4.1: use layout driver in global device cache

I have move that patch to the begining of the submit
toghther with the bug fixing of the new code

This here should just be squashed into the single objlayout
part of the get_devic_info handling

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index bcc8468..a4201d8 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -60,12 +60,12 @@ objio_free_deviceid_node(struct nfs4_deviceid_node *d)
 	kfree(de);
 }
 
-static struct objio_dev_ent *_dev_list_find(const struct nfs_client *clp,
+static struct objio_dev_ent *_dev_list_find(const struct nfs_server *nfss,
 	const struct nfs4_deviceid *d_id)
 {
 	struct nfs4_deviceid_node *d;
 
-	d = nfs4_find_get_deviceid(clp, d_id);
+	d = nfs4_find_get_deviceid(nfss->pnfs_curr_ld, nfss->nfs_client, d_id);
 	if (!d)
 		return NULL;
 	return container_of(d, struct objio_dev_ent, id_node);
@@ -141,7 +141,7 @@ static struct objio_dev_ent *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 
 	d_id = &objio_seg->comps[comp].oc_object_id.oid_device_id;
 
-	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode)->nfs_client, d_id);
+	ode = _dev_list_find(NFS_SERVER(pnfslay->plh_inode), d_id);
 	if (ode)
 		return ode;
 
-- 
1.7.2.3


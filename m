Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:50798 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755780AbaIOThV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 15:37:21 -0400
Date: Mon, 15 Sep 2014 22:37:07 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: hch@lst.de
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: re: pnfs/blocklayout: refactor extent processing
Message-ID: <20140915193707.GA19241@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Christoph Hellwig,

The patch ca0fe1dfa5ac: "pnfs/blocklayout: refactor extent
processing" from Sep 10, 2014, leads to the following static checker
warning:

	fs/nfs/blocklayout/blocklayout.c:558 bl_alloc_extent()
	warn: use 'gfp_mask' here instead of GFP_XXX?

fs/nfs/blocklayout/blocklayout.c
   544  static int
   545  bl_alloc_extent(struct xdr_stream *xdr, struct pnfs_layout_hdr *lo,
   546                  struct layout_verification *lv, struct list_head *extents,
   547                  gfp_t gfp_mask)
   548  {
   549          struct pnfs_block_extent *be;
   550          struct nfs4_deviceid id;
   551          int error;
   552          __be32 *p;
   553  
   554          p = xdr_inline_decode(xdr, 28 + NFS4_DEVICEID4_SIZE);
   555          if (!p)
   556                  return -EIO;
   557  
   558          be = kzalloc(sizeof(*be), GFP_NOFS);
                                          ^^^^^^^^
The caller uses gfp_mask for it's kzalloc().

   559          if (!be)
   560                  return -ENOMEM;
   561  
   562          memcpy(&id, p, NFS4_DEVICEID4_SIZE);
   563          p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);

Also on the same theme.

fs/nfs/blocklayout/dev.c
   227  static int
   228  bl_parse_concat(struct nfs_server *server, struct pnfs_block_dev *d,
   229                  struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
                                                                          ^^^^^^^^
   230  {
   231          struct pnfs_block_volume *v = &volumes[idx];
   232          u64 len = 0;
   233          int ret, i;
   234  
   235          d->children = kcalloc(v->concat.volumes_count,
   236                          sizeof(struct pnfs_block_dev), GFP_KERNEL);
                                                               ^^^^^^^^^^
   237          if (!d->children)
   238                  return -ENOMEM;
   239  
   240          for (i = 0; i < v->concat.volumes_count; i++) {
   241                  ret = bl_parse_deviceid(server, &d->children[i],
   242                                  volumes, v->concat.volumes[i], gfp_mask);
   243                  if (ret)
   244                          return ret;
   245  

fs/nfs/blocklayout/dev.c
   256  static int
   257  bl_parse_stripe(struct nfs_server *server, struct pnfs_block_dev *d,
   258                  struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
                                                                          ^^^^^^^^
   259  {
   260          struct pnfs_block_volume *v = &volumes[idx];
   261          u64 len = 0;
   262          int ret, i;
   263  
   264          d->children = kcalloc(v->stripe.volumes_count,
   265                          sizeof(struct pnfs_block_dev), GFP_KERNEL);
                                                               ^^^^^^^^^^
   266          if (!d->children)
   267                  return -ENOMEM;
   268  
   269          for (i = 0; i < v->stripe.volumes_count; i++) {
   270                  ret = bl_parse_deviceid(server, &d->children[i],
   271                                  volumes, v->stripe.volumes[i], gfp_mask);
   272                  if (ret)

regards,
dan carpenter

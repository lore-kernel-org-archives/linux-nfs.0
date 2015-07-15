Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27126 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbGOLNT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 07:13:19 -0400
Date: Wed, 15 Jul 2015 14:13:06 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: hch@lst.de
Cc: linux-nfs@vger.kernel.org
Subject: re: pnfs/blocklayout: allocate separate pages for the layoutcommit
 payload
Message-ID: <20150715111305.GA16569@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Christoph Hellwig,

This is old, and since no one has complained it's probably not a bug
but suspicious enough that I wanted to double check.

The patch 34dc93c2fc04: "pnfs/blocklayout: allocate separate pages
for the layoutcommit payload" from Sep 10, 2014, leads to the
following static checker warning:

	fs/nfs/blocklayout/extent_tree.c:559 ext_tree_prepare_commit()
	warn: potential pointer math issue ('start_p' is a pointer to 'unsigned int')

fs/nfs/blocklayout/extent_tree.c
   512  int
   513  ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg)
   514  {
   515          struct pnfs_block_layout *bl = BLK_LO2EXT(NFS_I(arg->inode)->layout);
   516          size_t count = 0, buffer_size = PAGE_SIZE;
   517          __be32 *start_p;
                ^^^^^^^^^^^^^^^
Declared here.

   518          int ret;
   519  
   520          dprintk("%s enter\n", __func__);
   521  
   522          arg->layoutupdate_page = alloc_page(GFP_NOFS);
   523          if (!arg->layoutupdate_page)
   524                  return -ENOMEM;
   525          start_p = page_address(arg->layoutupdate_page);
   526          arg->layoutupdate_pages = &arg->layoutupdate_page;
   527  
   528  retry:
   529          ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count);
   530          if (unlikely(ret)) {
   531                  ext_tree_free_commitdata(arg, buffer_size);
   532  
   533                  buffer_size = sizeof(__be32) + BL_EXTENT_SIZE * count;
   534                  count = 0;
   535  
   536                  arg->layoutupdate_pages =
   537                          kcalloc(DIV_ROUND_UP(buffer_size, PAGE_SIZE),
   538                                  sizeof(struct page *), GFP_NOFS);
   539                  if (!arg->layoutupdate_pages)
   540                          return -ENOMEM;
   541  
   542                  start_p = __vmalloc(buffer_size, GFP_NOFS, PAGE_KERNEL);
   543                  if (!start_p) {
   544                          kfree(arg->layoutupdate_pages);
   545                          return -ENOMEM;
   546                  }
   547  
   548                  goto retry;
   549          }
   550  
   551          *start_p = cpu_to_be32(count);
   552          arg->layoutupdate_len = sizeof(__be32) + BL_EXTENT_SIZE * count;
                ^^^^^^^^^^^^^^^^^^^^^
->layoutupdate_len is the size in bytes

   553  
   554          if (unlikely(arg->layoutupdate_pages != &arg->layoutupdate_page)) {
   555                  __be32 *p = start_p;
   556                  int i = 0;
   557  
   558                  for (p = start_p;
   559                       p < start_p + arg->layoutupdate_len;
   560                       p += PAGE_SIZE) {
                             ^^^^^^^^^^^^^^
Since "p" is also a pointer to unsigned int, it means we iterate the
correct number of times.

   561                          arg->layoutupdate_pages[i++] = vmalloc_to_page(p);

But it's possible that we are using the wrong value for "p" here.

   562                  }
   563          }
   564  
   565          dprintk("%s found %zu ranges\n", __func__, count);
   566          return 0;
   567  }

regards,
dan carpenter

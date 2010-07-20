Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35419 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab0GTIUp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 04:20:45 -0400
Received: by ewy23 with SMTP id 23so1538274ewy.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jul 2010 01:20:44 -0700 (PDT)
Message-ID: <4C455C58.8040300@panasas.com>
Date: Tue, 20 Jul 2010 11:20:40 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.35-rc5-2010-07-20
References: <4C111B9C.3080603@panasas.com> <4C1A4F0E.5070406@panasas.com>
In-Reply-To: <4C1A4F0E.5070406@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's the list of patches that went into the latest linux-pnfs tree as of 2010-07-20
since last update (pnfs-all-2.6.35-rc3-2010-07-01:

Note that this include more nfs41 patches that I pulled from
Trond's nfs-for-2.6.36 branch.

nfs-upstream:
  Benny Halevy     f42838f nfs: fix possible leak in nfs_proc_symlink
  Trond Myklebust  5936a2a NFSv4.1: Handle NFS4ERR_DELAY on SEQUENCE correctly
  Trond Myklebust  8df9417 NFSv4: Clean up struct nfs4_state_owner
  Trond Myklebust  8a5390e NFSv4: Ensure that we track the NFSv4 lock state in read/write requests.
  Trond Myklebust  f9f7435 NFSv4: Clean up for lockowner XDR encoding
  Trond Myklebust  ab9cd73 NFSv4: Add support for the RELEASE_LOCKOWNER operation
  Trond Myklebust  dba6dd5 NFSv4: Ensure the lockowners are labelled using the fl_owner and/or fl_pid

pnfs-submit:
  Boaz Harrosh     ad68cbb SQUASHME: pnfs-submit: Collapse pnfs_try_to_write_data code path and avoid big fat inlines
  Boaz Harrosh     f6d92c5 SQUASHME: pnfs-submit: Collapse pnfs_try_to_read_data code path and avoid big fat inlines
  Boaz Harrosh     3f15df9 SQUASHME: pnfs-submit: Collapse pnfs_try_to_commit code path and avoid big fat inlines
  Boaz Harrosh     a50ccf1 SQUASHME: pnfs-submit: Move _pnfs_clear_lseg_from_pages to pnfs.c
  Boaz Harrosh     1d58066 SQUASHME: pnfs-commit: Fix scariness in nfs4_clear_inode
  Boaz Harrosh     56dc2c0 SQUASHME: pnfs-submit: pnfs_return_layout remove surrounding #ifdef CONFIG_NFS_V4_1
  Andy Adamson     a3ae6d3 SQUASHME pnfs-submit: remove pnfs_init_once
  Andy Adamson     5969feb SQUASHME pnfs-submit remove pnfs_alloc_init_inode
  Andy Adamson     1a4f2af SQUASHME pnfs-submit: remove pnfs_destroy_inode
  Andy Adamson     a4831d8 SQUASHME pnfs-submit: set layoutcommit status after async error handler
  Andy Adamson     d2e80be SQUASHME pnfs-submit: set layoutget status after async error handler
  Fred Isaman      f13fcd2 SQUASHME pnfs-submit: add state flag for layoutcommit_needed
  Fred Isaman      5709bf4 SQUASHME: pnfs-submit: move pnfs_layout_suspend back to nfs_inode
  Andy Adamson     86c584f SQUASHME pnfs-submit embed pnfs_layout_type
  Andy Adamson     9fcd46d SQUASHME pnfs-submit: filelayout: use new alloc/free_layout API
  Andy Adamson     f4c135f SQUASHME pnfs-submit: rewrite layout allocation
  Andy Adamson     8cad754 SQUASHME pnfs-submit; fix pnfs_update_layout reference counting
  Andy Adamson     ef1af9c SQUASHME pnfs_submit: don't get a reference on boundary calculation
  Andy Adamson     24e681c SQUASHME pnfs-submit: don't reference the layout in init_lseg
  Andy Adamson     fcc3bf2 SQUASHME pnfs-submit: pnfs_update_layout always references the lseg
  Andy Adamson     9b66bb1 SQUASHME pnfs-submit: reference the layout when inserted into segs list
  Andy Adamson     971db12 SQUASHME pnfs-submit: rename put_layout to put_layout_locked
  Andy Adamson     185e07d SQUASHME pnfs-submit: reference layout across layoutcommit
  Andy Adamson     c730ea5 SQUASHME pnfs-submit: reference layout for layoutreturn
  Andy Adamson     0175ef7 SQUASHME pnfs-submit: remove put_layout from pnfs_free_layout
  Andy Adamson     ce23bd5 SQUASHME pnfs-submit: do not reference a layout in destroy_layout.
  Andy Adamson     ce7647a SQUASHME pnfs-submit: remove grab_current_layout
  Fred Isaman      a3f2877 pnfs-submit: Rely on full-file layout assumption to clean out some code
  Fred Isaman      871cac0 pnfs-submit: Remove readahead_range
  Fred Isaman      ccf3a9d pnfs-submit: Remove offset and count arguments from pnfs_update_layout
  Benny Halevy     27c4fb5 SQUASHME: pnfs-submit: check has_layout in __nfs4_close
  Benny Halevy     823ef07 SQUASHME: pnfs-submit: clean up nfs_lock_alloc_layout
  Benny Halevy     8e5ddfc SQUASHME: DEBUG: pnfs-submit: define and use BUG_ON_UNLOCKED_INO
  Andy Adamson     411990e SQUASHME pnfs-submit zero layout stateid on last layout segment removal
  Andy Adamson     d768d15 SQUASHME pnfs-submit: pnfs_try_to_commit can release nfs_write_data
  Andy Adamson     bec6c17 SQUASHME pnfs-submit remove gather_across_stripes policy
  Andy Adamson     0a2d01e SQUASHME pnfs-submit remove layoutret_on_setattr policy
  Andy Adamson     fc9abd7 SQUASHME pnfs-submit fix CONFIG_NFS_V4_1 not set compile error
  Andy Adamson     f37d86f SQUASHME pnfs-submit consolidate read_pagelist parameters
  Andy Adamson     749156d SQUASHME pnfs-submit filelayout use new read_pagelist API
  Andy Adamson     5e8daaf SQUASHME pnfs-submit consolidate write_pagelist parameters
  Andy Adamson     f1c98a4 SQUASHME pnfs-submit filelayout use new write_pagelist API
  Andy Adamson     467d776 SQUASHME pnfs-submit consolidate commit parameters
  Andy Adamson     6fbc8c2 SQUASHME pnfs-submit filelayout_commit use new API
  Andy Adamson     d2d5f50 SQUASHME pnfs-submit remove unused pnfs_return_layout_done
  Andy Adamson     ba814bf SQUASHME pnfs-submit remove unused nfs4_filelayout fields
  Andy Adamson     6ef6c01 SQUASHME pnfs-submit nfs4filelayout.c cleanup
  Andy Adamson     168ad0f8 SQUASHME pnfs-submit nfs4_filelayoutdev.c cleanup
  Andy Adamson     65f10b2 SQUASHME pnfs-submit get layoutget stateid from layout in xdr layer
  Andy Adamson     6be5ffb SQUASHME pnfs-submit get layoutreturn stateid from layout in xdr layer
  Andy Adamson     0980514 SQUASHME pnfs-submit remove unnecessary layoutreturn field
  Andy Adamson     c1edb65 SQUASHME pnfs-submit remove unnecessary layoutget field
  Benny Halevy     d8c9740 SQUASHME: pnfs-submit: add nr_pages back to write_pagelist api
  Benny Halevy     829e768 SQUASHME: pnfs-submit: filelayout: add nr_pages back to write_pagelist api
  Benny Halevy     d5b7f90 SQUASHME: pnfs-submit: use nfs_page_array_len in pnfs_try_to_read_data

pnfs:
  Andy Adamson     807eb70 pnfs-post-submit: restore and fix layoutret_on_setattr
  Andy Adamson     9c85e97 pnfs post-submit: restore gather_across_stripes policy
  Benny Halevy     0a21f6e pnfs-post-submit: reintroduce offset and count arguments from pnfs_update_layout"
  Benny Halevy     5260f76 pnfs-post-submit: Reintroduce readahead_range
  Benny Halevy     01ed291 pnfs-post-submit Reintroduce layout segment byte-range semantics
  Benny Halevy     7d3f96a pnfs-post-submit: reintroduce optional lseg referencing

pnfs-obj-all:
  Benny Halevy     e33bfbf SQUASHME: pnfs-obj: use new alloc/free_layout API
  Benny Halevy     d5ba2e9 SQUASHME: pnfs-obj: use new commit api
  Benny Halevy     c7f6fa5 SQAUSHME: pnfs-obj: use new read_pagelist api
  Benny Halevy     36bb622 SQUASHME: pnfs-obj: use new write_pagelist api

pnfs-block-all:
  Benny Halevy     d299751 SQUASHME: pnfs-block: use new alloc/free_layout API
  Benny Halevy     e8a4b7e SQUASHME: pnfs-block: use new commit api
  Benny Halevy     2f1320f SQUASHME: pnfs-block: use new read_pagelist api
  Benny Halevy     7e540f7 SQUASHME: pnfs-block: use new write_pagelist api

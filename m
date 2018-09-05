Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:53965 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727501AbeIFDw3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 23:52:29 -0400
Date: Thu, 6 Sep 2018 07:15:55 +0800
From: kbuild test robot <lkp@intel.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: [nfs:testing 45/45] include/linux/list.h:125:25: sparse: context
 imbalance in 'nfs4_put_open_state' - unexpected unlock
Message-ID: <201809060746.zghfLfFA%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   c925dd1e826cb81f1dafef462b1326ec33913b8e
commit: c925dd1e826cb81f1dafef462b1326ec33913b8e [45/45] NFSv4: Convert struct nfs4_state to use refcount_t
reproduce:
        # apt-get install sparse
        git checkout c925dd1e826cb81f1dafef462b1326ec33913b8e
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> include/linux/list.h:125:25: sparse: context imbalance in 'nfs4_put_open_state' - unexpected unlock
   fs/nfs/nfs4state.c:930:20: sparse: context imbalance in 'nfs4_put_lock_state' - unexpected unlock

vim +/nfs4_put_open_state +125 include/linux/list.h

3c18d4de Linus Torvalds 2011-02-18  122  
^1da177e Linus Torvalds 2005-04-16  123  static inline void list_del(struct list_head *entry)
^1da177e Linus Torvalds 2005-04-16  124  {
0cd340dc Kees Cook      2016-08-17 @125  	__list_del_entry(entry);
^1da177e Linus Torvalds 2005-04-16  126  	entry->next = LIST_POISON1;
^1da177e Linus Torvalds 2005-04-16  127  	entry->prev = LIST_POISON2;
^1da177e Linus Torvalds 2005-04-16  128  }
^1da177e Linus Torvalds 2005-04-16  129  

:::::: The code at line 125 was first introduced by commit
:::::: 0cd340dcb05c4a43742fe156f36737bb2a321bfd list: Split list_del() debug checking into separate function

:::::: TO: Kees Cook <keescook@chromium.org>
:::::: CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

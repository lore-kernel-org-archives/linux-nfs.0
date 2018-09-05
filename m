Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:54242 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727373AbeIFC6j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 22:58:39 -0400
Date: Thu, 6 Sep 2018 06:25:21 +0800
From: kbuild test robot <lkp@intel.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: [nfs:testing 41/45] include/linux/rculist.h:130:25: sparse: context
 imbalance in 'nfs_put_lock_context' - unexpected unlock
Message-ID: <201809060614.OXUdpoYn%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   c925dd1e826cb81f1dafef462b1326ec33913b8e
commit: 9d097c9f0dd73d0e02ddfceb112e3bcdd8915524 [41/45] NFS: Convert lookups of the lock context to RCU
reproduce:
        # apt-get install sparse
        git checkout 9d097c9f0dd73d0e02ddfceb112e3bcdd8915524
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/nfs_fs.h:566:16: sparse: expression using sizeof(void)
   include/linux/nfs_fs.h:566:16: sparse: expression using sizeof(void)
   include/linux/nfs_fs.h:566:16: sparse: expression using sizeof(void)
   include/linux/nfs_fs.h:566:16: sparse: expression using sizeof(void)
   include/linux/nfs_fs.h:566:16: sparse: expression using sizeof(void)
>> include/linux/rculist.h:130:25: sparse: context imbalance in 'nfs_put_lock_context' - unexpected unlock
   include/linux/list.h:125:25: sparse: context imbalance in '__put_nfs_open_context' - unexpected unlock

vim +/nfs_put_lock_context +130 include/linux/rculist.h

82524746 Franck Bui-Huu 2008-05-12  103  
82524746 Franck Bui-Huu 2008-05-12  104  /**
82524746 Franck Bui-Huu 2008-05-12  105   * list_del_rcu - deletes entry from list without re-initialization
82524746 Franck Bui-Huu 2008-05-12  106   * @entry: the element to delete from the list.
82524746 Franck Bui-Huu 2008-05-12  107   *
82524746 Franck Bui-Huu 2008-05-12  108   * Note: list_empty() on entry does not return true after this,
82524746 Franck Bui-Huu 2008-05-12  109   * the entry is in an undefined state. It is useful for RCU based
82524746 Franck Bui-Huu 2008-05-12  110   * lockfree traversal.
82524746 Franck Bui-Huu 2008-05-12  111   *
82524746 Franck Bui-Huu 2008-05-12  112   * In particular, it means that we can not poison the forward
82524746 Franck Bui-Huu 2008-05-12  113   * pointers that may still be used for walking the list.
82524746 Franck Bui-Huu 2008-05-12  114   *
82524746 Franck Bui-Huu 2008-05-12  115   * The caller must take whatever precautions are necessary
82524746 Franck Bui-Huu 2008-05-12  116   * (such as holding appropriate locks) to avoid racing
82524746 Franck Bui-Huu 2008-05-12  117   * with another list-mutation primitive, such as list_del_rcu()
82524746 Franck Bui-Huu 2008-05-12  118   * or list_add_rcu(), running on this same list.
82524746 Franck Bui-Huu 2008-05-12  119   * However, it is perfectly legal to run concurrently with
82524746 Franck Bui-Huu 2008-05-12  120   * the _rcu list-traversal primitives, such as
82524746 Franck Bui-Huu 2008-05-12  121   * list_for_each_entry_rcu().
82524746 Franck Bui-Huu 2008-05-12  122   *
82524746 Franck Bui-Huu 2008-05-12  123   * Note that the caller is not permitted to immediately free
82524746 Franck Bui-Huu 2008-05-12  124   * the newly deleted entry.  Instead, either synchronize_rcu()
82524746 Franck Bui-Huu 2008-05-12  125   * or call_rcu() must be used to defer freeing until an RCU
82524746 Franck Bui-Huu 2008-05-12  126   * grace period has elapsed.
82524746 Franck Bui-Huu 2008-05-12  127   */
82524746 Franck Bui-Huu 2008-05-12  128  static inline void list_del_rcu(struct list_head *entry)
82524746 Franck Bui-Huu 2008-05-12  129  {
559f9bad Dave Jones     2012-03-14 @130  	__list_del_entry(entry);
82524746 Franck Bui-Huu 2008-05-12  131  	entry->prev = LIST_POISON2;
82524746 Franck Bui-Huu 2008-05-12  132  }
82524746 Franck Bui-Huu 2008-05-12  133  

:::::: The code at line 130 was first introduced by commit
:::::: 559f9badd11ddf399f88b18b4c0f110fd511ae53 rcu: List-debug variants of rcu list routines.

:::::: TO: Dave Jones <davej@redhat.com>
:::::: CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

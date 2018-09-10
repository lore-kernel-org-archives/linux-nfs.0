Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18513 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726603AbeIJXpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Sep 2018 19:45:17 -0400
Date: Tue, 11 Sep 2018 02:48:40 +0800
From: kbuild test robot <lkp@intel.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: [nfs:testing 39/48] net/sunrpc/xprt.c:893:17: sparse: cast from
 restricted __be32
Message-ID: <201809110235.FqzSq75A%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   11dddfd20094d3d05af7aa2ac8ef0c9435a11856
commit: 19568b491e9a59b2e5a07ce18e3194625e59aa6c [39/48] SUNRPC: Convert xprt receive queue to use an rbtree
reproduce:
        # apt-get install sparse
        git checkout 19568b491e9a59b2e5a07ce18e3194625e59aa6c
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/sunrpc/xprt.c:893:17: sparse: cast from restricted __be32
   net/sunrpc/xprt.c:893:29: sparse: cast from restricted __be32
   net/sunrpc/xprt.c:1512:32: sparse: expression using sizeof(void)
   net/sunrpc/xprt.c:1512:32: sparse: expression using sizeof(void)

vim +893 net/sunrpc/xprt.c

   882	
   883	enum xprt_xid_rb_cmp {
   884		XID_RB_EQUAL,
   885		XID_RB_LEFT,
   886		XID_RB_RIGHT,
   887	};
   888	static enum xprt_xid_rb_cmp
   889	xprt_xid_cmp(__be32 xid1, __be32 xid2)
   890	{
   891		if (xid1 == xid2)
   892			return XID_RB_EQUAL;
 > 893		return (u32)xid1 < (u32)xid2 ? XID_RB_LEFT : XID_RB_RIGHT;
   894	}
   895	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

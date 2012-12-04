Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga09.intel.com ([134.134.136.24]:58349 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436Ab2LDXEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 18:04:34 -0500
Date: Wed, 05 Dec 2012 07:03:58 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [nfs:devel 83/89] fs/nfsd/nfssvc.c:306:2: warning: format '%u'
 expects argument of type 'unsigned int', but argument 3 has type 'long
 unsigned int'
Message-ID: <50be815e.k+1HrQIWo0JgAoaq%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
head:   5aa86f21b8166d55aa4cf8c30130743c686abc6d
commit: d0aeb64e7d5478dbab86933278fdf3d0f1082b8c [83/89] NFSD: Make DRC memory limits work with dynamic slot allocation
config: make ARCH=m68k allmodconfig

All warnings:

fs/nfsd/nfssvc.c: In function 'set_max_drc':
fs/nfsd/nfssvc.c:306:2: warning: format '%u' expects argument of type 'unsigned int', but argument 3 has type 'long unsigned int' [-Wformat]

vim +306 fs/nfsd/nfssvc.c

c3d06f9c Andy Adamson    2009-04-03  290   * NFSv4.1 server might want to use more memory for a DRC than a machine
c3d06f9c Andy Adamson    2009-04-03  291   * with mutiple services.
c3d06f9c Andy Adamson    2009-04-03  292   *
c3d06f9c Andy Adamson    2009-04-03  293   * Impose a hard limit on the number of pages for the DRC which varies
c3d06f9c Andy Adamson    2009-04-03  294   * according to the machines free pages. This is of course only a default.
c3d06f9c Andy Adamson    2009-04-03  295   *
c3d06f9c Andy Adamson    2009-04-03  296   * For now this is a #defined shift which could be under admin control
c3d06f9c Andy Adamson    2009-04-03  297   * in the future.
c3d06f9c Andy Adamson    2009-04-03  298   */
c3d06f9c Andy Adamson    2009-04-03  299  static void set_max_drc(void)
c3d06f9c Andy Adamson    2009-04-03  300  {
6a14dd1a Andy Adamson    2009-07-27  301  	#define NFSD_DRC_SIZE_SHIFT	10
0c193054 Andy Adamson    2009-07-27  302  	nfsd_drc_max_mem = (nr_free_buffer_pages()
0c193054 Andy Adamson    2009-07-27  303  					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
0c193054 Andy Adamson    2009-07-27  304  	nfsd_drc_mem_used = 0;
4bd9b0f4 Andy Adamson    2009-06-24  305  	spin_lock_init(&nfsd_drc_lock);
0c193054 Andy Adamson    2009-07-27 @306  	dprintk("%s nfsd_drc_max_mem %u \n", __func__, nfsd_drc_max_mem);
c3d06f9c Andy Adamson    2009-04-03  307  }
bedbdd8b Neil Brown      2008-06-10  308  
87b0fc7d J. Bruce Fields 2012-01-30  309  static int nfsd_get_default_max_blksize(void)
02a375f0 NeilBrown       2006-10-02  310  {
87b0fc7d J. Bruce Fields 2012-01-30  311  	struct sysinfo i;
87b0fc7d J. Bruce Fields 2012-01-30  312  	unsigned long long target;
87b0fc7d J. Bruce Fields 2012-01-30  313  	unsigned long ret;
bedbdd8b Neil Brown      2008-06-10  314  

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga09.intel.com ([134.134.136.24]:30875 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754482Ab3ASBoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2013 20:44:04 -0500
Date: Sat, 19 Jan 2013 09:42:41 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [nfs:bugfixes 11/11] fs/nfs/nfs4client.c:351:8: error: label at
 end of compound statement
Message-ID: <50f9fa11.yIdHaCJJ8S6lX26G%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git bugfixes
head:   8ae0dc0ae64c9913c90f550d3c6b724313883fff
commit: 8ae0dc0ae64c9913c90f550d3c6b724313883fff [11/11] NFSv4: Fix NFSv4.0 trunking discovery
config: make ARCH=i386 allmodconfig

All error/warnings:

   fs/nfs/nfs4client.c: In function 'nfs40_walk_client_list':
>> fs/nfs/nfs4client.c:351:8: error: label at end of compound statement

vim +351 fs/nfs/nfs4client.c

   345				prev = NULL;
   346				*result = pos;
   347				dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
   348					__func__, pos, atomic_read(&pos->cl_count));
   349			default:
   350				goto out;
 > 351			case -NFS4ERR_STALE_CLIENTID:
   352			}
   353	
   354			spin_lock(&nn->nfs_client_lock);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

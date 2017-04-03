Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751008AbdDCJnH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 05:43:07 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "kbuild test robot" <lkp@intel.com>
Cc: kbuild-all@01.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Jeff Layton" <jlayton@poochiereds.net>, bfields@fieldses.org,
        "Miklos Szeredi" <miklos@szeredi.hu>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 4/6] NFS: Add an iocounter wait function for async RPC
 tasks
Date: Mon, 03 Apr 2017 05:42:57 -0400
Message-ID: <8FD729A8-AF16-4134-9CFC-6CB9232E4E61@redhat.com>
In-Reply-To: <201704022250.GuhpAWeg%fengguang.wu@intel.com>
References: <201704022250.GuhpAWeg%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ah, thanks robot.  I didn't notice the:

172 #if IS_ENABLED(CONFIG_NFS_V4)
173     u32         attr_bitmask[3];/* V4 bitmask representing the set
...
199     struct rpc_wait_queue   uoc_rpcwaitq;

I will re-post this one.

On 2 Apr 2017, at 10:29, kbuild test robot wrote:

> Hi Benjamin,
>
> [auto build test ERROR on nfs/linux-next]
> [also build test ERROR on v4.11-rc4 next-20170331]
> [if your patch is applied to the wrong git tree, please drop us a note 
> to help improve the system]
>
> url:    
> https://github.com/0day-ci/linux/commits/Benjamin-Coddington/Skipped-unlocks/20170402-195846
> base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git 
> linux-next
> config: cris-etrax-100lx_v2_defconfig (attached as .config)
> compiler: cris-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget 
> https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross 
> -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=cris
>
> All errors (new ones prefixed by >>):
>
>    fs/nfs/pagelist.c: In function 'nfs_async_iocounter_wait':
>>> fs/nfs/pagelist.c:126:34: error: 'struct nfs_server' has no member 
>>> named 'uoc_rpcwaitq'
>       rpc_sleep_on(&NFS_SERVER(inode)->uoc_rpcwaitq, task, NULL);
>                                      ^~
>    fs/nfs/pagelist.c:131:45: error: 'struct nfs_server' has no member 
> named 'uoc_rpcwaitq'
>       rpc_wake_up_queued_task(&NFS_SERVER(inode)->uoc_rpcwaitq, task);
>                                                 ^~
>    fs/nfs/pagelist.c: In function 'nfs_clear_request':
>    fs/nfs/pagelist.c:425:50: error: 'struct nfs_server' has no member 
> named 'uoc_rpcwaitq'
>         rpc_wake_up(&NFS_SERVER(d_inode(ctx->dentry))->uoc_rpcwaitq);
>                                                      ^~
>
> vim +126 fs/nfs/pagelist.c
>
>    120	{
>    121		struct nfs_lock_context *l_ctx = data;
>    122		struct inode *inode = d_inode(l_ctx->open_context->dentry);
>    123		bool ret = false;
>    124	
>    125		if (atomic_read(&l_ctx->io_count) > 0) {
>> 126			rpc_sleep_on(&NFS_SERVER(inode)->uoc_rpcwaitq, task, NULL);
>    127			ret = true;
>    128		}
>    129	
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology 
> Center
> https://lists.01.org/pipermail/kbuild-all                   Intel 
> Corporation

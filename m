Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33414 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756009AbdBQTd5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 14:33:57 -0500
Date: Fri, 17 Feb 2017 14:33:55 -0500
To: kbuild test robot <lkp@intel.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, kbuild-all@01.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH 3/3] nfsd4: simplify getacl decoding
Message-ID: <20170217193355.GF10894@fieldses.org>
References: <1487349854-9732-4-git-send-email-bfields@redhat.com>
 <201702180315.sUnb0Muq%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201702180315.sUnb0Muq%fengguang.wu@intel.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whoops, forgot to retst after a last minute change!  Fixed locally.
Also fixed up the subject lines that refer to "nfsd".

--b.

On Sat, Feb 18, 2017 at 03:15:11AM +0800, kbuild test robot wrote:
> Hi Bruce,
> 
> [auto build test ERROR on nfs/linux-next]
> [also build test ERROR on v4.10-rc8 next-20170217]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/J-Bruce-Fields/getacl-fixes/20170218-022320
> base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
> config: x86_64-randconfig-x015-201707 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    fs/nfs/nfs4proc.c: In function 'nfs4_do_get_acl':
> >> fs/nfs/nfs4proc.c:5095:2: error: 'ret' undeclared (first use in this function)
>      ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
>      ^~~
>    fs/nfs/nfs4proc.c:5095:2: note: each undeclared identifier is reported only once for each function it appears in
> >> fs/nfs/nfs4proc.c:5104:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
> 
> vim +/ret +5095 fs/nfs/nfs4proc.c
> 
> cfc94798 Weston Andros Adamson 2017-02-17  5089  		return -ENOMEM;
> 5a006899 Sachin Prabhu         2012-04-17  5090  
> cfc94798 Weston Andros Adamson 2017-02-17  5091  	args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;
> 5a006899 Sachin Prabhu         2012-04-17  5092  
> cfc94798 Weston Andros Adamson 2017-02-17  5093  	dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
> cfc94798 Weston Andros Adamson 2017-02-17  5094  		__func__, buf, buflen, args.acl_len);
> bf118a34 Andy Adamson          2011-12-07 @5095  	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
> bf118a34 Andy Adamson          2011-12-07  5096  			     &msg, &args.seq_args, &res.seq_res, 0);
> 942bf94d J. Bruce Fields       2017-02-17  5097  	if (ret == 0)
> 1f1ea6c2 Trond Myklebust       2012-08-26  5098  		ret = res.acl_len;
> 942bf94d J. Bruce Fields       2017-02-17  5099  
> cfc94798 Weston Andros Adamson 2017-02-17  5100  	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
> bf118a34 Andy Adamson          2011-12-07  5101  		__free_page(pages[i]);
> 331818f1 Trond Myklebust       2012-02-03  5102  	__free_page(res.acl_scratch);
> e50a1c2e J. Bruce Fields       2005-06-22  5103  	return ret;
> e50a1c2e J. Bruce Fields       2005-06-22 @5104  }
> e50a1c2e J. Bruce Fields       2005-06-22  5105  
> 942bf94d J. Bruce Fields       2017-02-17  5106  /*
> 942bf94d J. Bruce Fields       2017-02-17  5107   * The getxattr API returns the required buffer length when called with a
> 
> :::::: The code at line 5095 was first introduced by commit
> :::::: bf118a342f10dafe44b14451a1392c3254629a1f NFSv4: include bitmap in nfsv4 get acl data
> 
> :::::: TO: Andy Adamson <andros@netapp.com>
> :::::: CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



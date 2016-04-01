Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33512 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbcDAPnn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Apr 2016 11:43:43 -0400
Received: by mail-io0-f179.google.com with SMTP id a129so147844228ioe.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 Apr 2016 08:43:42 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/2] pnfs: set NFS_IOHDR_REDO in pnfs_read_resend_pnfs
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <201604012319.8pUQn3r9%fengguang.wu@intel.com>
Date: Fri, 1 Apr 2016 11:43:40 -0400
Cc: kbuild-all@01.org, Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <0BC06C2F-3ADC-4BF7-B82E-BD014B0C23E2@primarydata.com>
References: <201604012319.8pUQn3r9%fengguang.wu@intel.com>
To: kbuild test robot <lkp@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 1, 2016, at 11:28 AM, kbuild test robot <lkp@intel.com> wrote:
> 
> Hi Weston,
> 
> [auto build test WARNING on v4.6-rc1]
> [also build test WARNING on next-20160401]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Weston-Andros-Adamson/pnfs-set-NFS_IOHDR_REDO-in-pnfs_read_resend_pnfs/20160401-223208
> config: i386-allmodconfig (attached as .config)
> reproduce:
>        # save the attached .config to linux build tree
>        make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>   fs/nfs/pnfs.c: In function 'pnfs_do_read':
>>> fs/nfs/pnfs.c:2164:6: warning: unused variable 'err' [-Wunused-variable]
>     int err = 0;
>         ^

Thanks bot! Fixed and reposted.

-dros

> 
> vim +/err +2164 fs/nfs/pnfs.c
> 
> ceb11e13 Peng Tao              2014-11-10  2148  	struct nfs_pageio_descriptor pgio;
> ceb11e13 Peng Tao              2014-11-10  2149  
> a5073dc2 Weston Andros Adamson 2016-04-01  2150  	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
> a5073dc2 Weston Andros Adamson 2016-04-01  2151  		nfs_pageio_init_read(&pgio, hdr->inode, false,
> a5073dc2 Weston Andros Adamson 2016-04-01  2152  					hdr->completion_ops);
> a5073dc2 Weston Andros Adamson 2016-04-01  2153  		hdr->task.tk_status = nfs_pageio_resend(&pgio, hdr);
> a5073dc2 Weston Andros Adamson 2016-04-01  2154  	}
> ceb11e13 Peng Tao              2014-11-10  2155  }
> ceb11e13 Peng Tao              2014-11-10  2156  EXPORT_SYMBOL_GPL(pnfs_read_resend_pnfs);
> ceb11e13 Peng Tao              2014-11-10  2157  
> 493292dd Trond Myklebust       2011-07-13  2158  static void
> 7f714720 Weston Andros Adamson 2014-05-15  2159  pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
> 493292dd Trond Myklebust       2011-07-13  2160  {
> 493292dd Trond Myklebust       2011-07-13  2161  	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
> 493292dd Trond Myklebust       2011-07-13  2162  	struct pnfs_layout_segment *lseg = desc->pg_lseg;
> 493292dd Trond Myklebust       2011-07-13  2163  	enum pnfs_try_status trypnfs;
> ceb11e13 Peng Tao              2014-11-10 @2164  	int err = 0;
> 493292dd Trond Myklebust       2011-07-13  2165  
> d45f60c6 Weston Andros Adamson 2014-06-09  2166  	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
> ceb11e13 Peng Tao              2014-11-10  2167  	if (trypnfs == PNFS_TRY_AGAIN)
> a5073dc2 Weston Andros Adamson 2016-04-01  2168  		pnfs_read_resend_pnfs(hdr);
> a5073dc2 Weston Andros Adamson 2016-04-01  2169  	if (trypnfs == PNFS_NOT_ATTEMPTED || hdr->task.tk_status)
> d45f60c6 Weston Andros Adamson 2014-06-09  2170  		pnfs_read_through_mds(desc, hdr);
> 493292dd Trond Myklebust       2011-07-13  2171  }
> 493292dd Trond Myklebust       2011-07-13  2172  
> 
> :::::: The code at line 2164 was first introduced by commit
> :::::: ceb11e13df3e78b450730c615037133c57b90c3b pnfs: allow LD to ask to resend read through pnfs
> 
> :::::: TO: Peng Tao <tao.peng@primarydata.com>
> :::::: CC: Tom Haynes <loghyr@primarydata.com>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> <.config.gz>


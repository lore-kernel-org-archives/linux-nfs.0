Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D258AC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 06:47:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8BDCB2073D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 06:47:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728884AbfACGrm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 01:47:42 -0500
Received: from mga11.intel.com ([192.55.52.93]:12232 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727055AbfACGrm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 01:47:42 -0500
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Jan 2019 22:47:41 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,433,1539673200"; 
   d="gz'50?scan'50,208,50";a="288474086"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga005.jf.intel.com with ESMTP; 02 Jan 2019 22:47:39 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
        (envelope-from <lkp@intel.com>)
        id 1gewn5-0009CK-Di; Thu, 03 Jan 2019 14:47:39 +0800
Date:   Thu, 3 Jan 2019 14:45:34 +0800
From:   kbuild test robot <lkp@intel.com>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     kbuild-all@01.org, Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix TCP receive code on archs with
 flush_dcache_page()
Message-ID: <201901031440.VLdfbkeB%fengguang.wu@intel.com>
References: <20190103004211.12404-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Content-Disposition: inline
In-Reply-To: <20190103004211.12404-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Trond,

I love your patch! Perhaps something to improve:

[auto build test WARNING on nfs/linux-next]
[also build test WARNING on v4.20 next-20190102]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Trond-Myklebust/SUNRPC-Fix-TCP-receive-code-on-archs-with-flush_dcache_page/20190103-113507
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
config: m68k-sun3_defconfig (attached as .config)
compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=m68k 

All warnings (new ones prefixed by >>):

   In file included from include/linux/pagemap.h:8:0,
                    from net/sunrpc/xprtsock.c:27:
   net/sunrpc/xprtsock.c: In function 'xs_flush_bvec':
   net/sunrpc/xprtsock.c:396:24: error: 'struct bio_vec' has no member named 'page'; did you mean 'bv_page'?
      flush_dcache_page(bv.page);
                           ^
   include/linux/mm.h:1258:48: note: in definition of macro 'page_address'
    #define page_address(page) lowmem_page_address(page)
                                                   ^~~~
>> net/sunrpc/xprtsock.c:396:3: note: in expansion of macro 'flush_dcache_page'
      flush_dcache_page(bv.page);
      ^~~~~~~~~~~~~~~~~

vim +/flush_dcache_page +396 net/sunrpc/xprtsock.c

   383	
   384	#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
   385	static void
   386	xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
   387	{
   388		struct bvec_iter bi, __start = {
   389			.bi_size = count,
   390		};
   391		struct bio_vec bv;
   392	
   393		bvec_iter_advance(bvec, &__start, seek & PAGE_MASK);
   394	
   395		for_each_bvec(bv, bvec, bi, __start)
 > 396			flush_dcache_page(bv.page);
   397	}
   398	#else
   399	static inline void
   400	xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
   401	{
   402	}
   403	#endif
   404	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--nFreZHaLTZJo0R7j
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
xFFVOAXjujzT3z8E2KBEPboBAOp9pYzcugAA

--nFreZHaLTZJo0R7j--

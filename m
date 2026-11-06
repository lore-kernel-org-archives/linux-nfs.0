Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=192.198.163.17
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793968112;
	b=wmoOXpsxCAtS9L7Ixv+zmCk1HlOvnYlC1bp1yd0rEB/0BSAgh7aEfazGlhDLbStYJ/Zz
	 TSf/g9EYMn4G5r/rd5OPv2XzHmfuuBNQEwxHwNPuj1CCJUYc+80GfzvE9eZqVoHhx1fEN
	 fqK9U6JITQBeEl0hxUVFYJ7xN6iFNn0lI7N/aG1F8WL6mJJ3Dpd6O6ELt3jpCd+/IVD4W
	 Mvb/I+DKMy+B26HhDKUpMfqL+iORuEyK1SmG810IvyDsWMr+r3A+B6sBDnQ6FY3Rn1TVc
	 zj7Z2kfzco8nU20l0u/3KWZcgdlPe1V9rikrZQN7iJFH2CHgUaaI6nx0sKKLCqw1L/g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793968112;
	h=DMARC-Filter:DKIM-Signature:X-CSE-ConnectionGUID:X-CSE-MsgGUID:
	 X-IronPort-AV:X-IronPort-AV:Received:X-CSE-ConnectionGUID:
	 X-CSE-MsgGUID:X-ExtLoop1:X-IronPort-AV:Received:Received:Date:From:To:
	 Cc:Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=hQVrnxdz+rbVpJRSfgeT0cSc/1aHJR+DP3Q1DQOKUSE=;
	b=uWgvAouLuc1ZNx7s6MC0aYoa9D4tGozdTth7UMdYIJbmKI87sOduwmoXHwYJi921E+QW
	 LOglxP8mru7902tKNtPX89HnucBlEkQ5wDdVPbji/q9Vea2lvLO4vVrf3ch2vHbhgQ03S
	 cfPxB9l2YiNas/BfqeID6L6+eWWjtAuim/iq37VTJGHWguJD3na2/wf0qszQI50aUJBxX
	 ny1GapUqfwSbY8+KsUhA+md3Yc99d8HiqkxDkpS/FZREhJZ72v0pSo0mBUhHZUln8T27U
	 qczOXzKSbGlB0SEBTEE6af9afNmVgSZVEWxpoDK/1cQ2nhAw1XVo79nigFELhC301hA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=intel.com;
	spf=pass smtp.mailfrom=intel.com;
	dkim=pass header.d=intel.com header.i=@intel.com header.a=rsa-sha256 header.s=Intel header.b=igiRGWuS;
	arc=none smtp.remote-ip=192.198.163.17
Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.17])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EC9E606A333
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 12:28:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1EC9E606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=intel.com header.i=@intel.com header.a=rsa-sha256 header.s=Intel header.b=igiRGWuS
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1793968112; x=1825504112;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=jUA+TebI3m9/LhLb8tKLu6TX6W1ZynxPrDltBatVwPc=;
  b=igiRGWuSEd+5s3skViZsEe9aBV6k086+7unLKQuGI4qCgmbWLxoADRfD
   b7pdDb2dtjT5Wo9IcsDfvgmslT/V+N88kHAmLQdGyBFlj59OSpbGTOzVt
   a8xocQQpjTm4gQrazgQ4UpyfhqBDUZ7oBjJpHjC84Rw2R2fz79ZyPT9ss
   CDnxI7nLXvTPnW5TNODev7P/sUQYJ6cOH3uIlGp77liCka+7lkRR4OH23
   a48pp6UPttjaoB3gE5awLitf/AsH940rLqPec7kwvBJV5REU0Y4jcGtrU
   3zJte0FDOLd85gzQb0HxSYMdDvLv4JRwqZXkuh9JllnapEKBGcVKqGDvo
   g==;
X-CSE-ConnectionGUID: taUDdUhGRvecTUrEg78o/w==
X-CSE-MsgGUID: 6pnZko7PRUmnxxRzc0gNOw==
X-IronPort-AV: E=McAfee;i="6800,10657,11957"; a="2783317"
X-IronPort-AV: E=Sophos;i="6.27,197,1787036400"; 
   d="scan'208";a="2783317"
Received: from orviesa002.jf.intel.com ([10.64.159.142])
  by fmvoesa111.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 06 Nov 2026 04:28:31 -0800
X-CSE-ConnectionGUID: LDJQMKt1RRSdHbxIIuWJIg==
X-CSE-MsgGUID: IN5rR5B7TBqELLczD0z1Ng==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.27,197,1787036400"; 
   d="scan'208";a="7315719"
Received: from lkp-server01.sh.intel.com (HELO 0caa9d2d175c) ([10.239.97.150])
  by orviesa002.jf.intel.com with ESMTP; 06 Nov 2026 04:28:30 -0800
Received: from kbuild by 0caa9d2d175c with local (Exim 4.98.2)
	(envelope-from <lkp@intel.com>)
	id 1xPJ3S-00000000pFP-3hkN;
	Fri, 06 Nov 2026 12:28:26 +0000
Date: Fri, 6 Nov 2026 20:28:20 +0800
From: kernel test robot <lkp@intel.com>
To: Mike Snitzer <snitzer@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: llvm@lists.linux.dev, oe-kbuild-all@lists.linux.dev,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org, Mike Snitzer <snitzer@hammerspace.com>
Subject: Re: [PATCH v2 01/12] NFSv4/flexfiles: move layoutstats accounting to
 a per-stripe lock
Message-ID: <202611062010.UcNJzsW9-lkp@intel.com>
References: <20261106001251.73472-2-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261106001251.73472-2-snitzer@kernel.org>

Hi Mike,

kernel test robot noticed the following build errors:

[auto build test ERROR on 8cdff0c1549d3fce6bb652e6bc5dd7546e1cd1e3]

url:    https://github.com/intel-lab-lkp/linux/commits/Mike-Snitzer/NFSv4-flexfiles-move-layoutstats-accounting-to-a-per-stripe-lock/20261105-191238
base:   8cdff0c1549d3fce6bb652e6bc5dd7546e1cd1e3
patch link:    https://lore.kernel.org/r/20261106001251.73472-2-snitzer%40kernel.org
patch subject: [PATCH v2 01/12] NFSv4/flexfiles: move layoutstats accounting to a per-stripe lock
config: arm-mps2_defconfig (https://download.01.org/0day-ci/archive/20261106/202611062010.UcNJzsW9-lkp@intel.com/config)
compiler: clang version 24.0.0git (https://github.com/llvm/llvm-project 812626a41399a1d464a0d69627ab45c83b8ebfb9)
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20261106/202611062010.UcNJzsW9-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202611062010.UcNJzsW9-lkp@intel.com/

All errors (new ones prefixed by >>):

   In file included from fs/nfs/flexfilelayout/flexfilelayout.c:10:
   In file included from include/linux/nfs_fs.h:22:
   In file included from include/linux/in.h:19:
   In file included from include/uapi/linux/in.h:25:
   In file included from include/linux/socket.h:8:
   In file included from include/linux/uio.h:8:
   In file included from include/linux/kernel.h:23:
   In file included from include/linux/bitops.h:67:
   In file included from arch/arm/include/asm/bitops.h:245:
   In file included from include/asm-generic/bitops/lock.h:5:
   In file included from include/linux/atomic.h:7:
   In file included from arch/arm/include/asm/atomic.h:16:
>> arch/arm/include/asm/cmpxchg.h:260:1: error: instruction requires: !armv*m
     260 | "1:     ldrexd          %1, %H1, [%3]\n"
         | ^
   <inline asm>:1:5: note: instantiated into assembly here
       1 |         1:      ldrexd          r2, r3, [r0]
         |                 ^
   In file included from fs/nfs/flexfilelayout/flexfilelayout.c:10:
   In file included from include/linux/nfs_fs.h:22:
   In file included from include/linux/in.h:19:
   In file included from include/uapi/linux/in.h:25:
   In file included from include/linux/socket.h:8:
   In file included from include/linux/uio.h:8:
   In file included from include/linux/kernel.h:23:
   In file included from include/linux/bitops.h:67:
   In file included from arch/arm/include/asm/bitops.h:245:
   In file included from include/asm-generic/bitops/lock.h:5:
   In file included from include/linux/atomic.h:7:
   In file included from arch/arm/include/asm/atomic.h:16:
   arch/arm/include/asm/cmpxchg.h:264:2: error: instruction requires: !armv*m
     264 | "       strexd          %0, %5, %H5, [%3]\n"
         |  ^
   <inline asm>:5:2: note: instantiated into assembly here
       5 |         strexd          r1, r10, r11, [r0]
         |         ^
   2 errors generated.


vim +260 arch/arm/include/asm/cmpxchg.h

e001bbae7147b1 Russell King 2015-05-26  249  
2523c67bb6962f Will Deacon  2013-10-09  250  static inline unsigned long long __cmpxchg64(unsigned long long *ptr,
2523c67bb6962f Will Deacon  2013-10-09  251  					     unsigned long long old,
2523c67bb6962f Will Deacon  2013-10-09  252  					     unsigned long long new)
2523c67bb6962f Will Deacon  2013-10-09  253  {
2523c67bb6962f Will Deacon  2013-10-09  254  	unsigned long long oldval;
2523c67bb6962f Will Deacon  2013-10-09  255  	unsigned long res;
2523c67bb6962f Will Deacon  2013-10-09  256  
c32ffce0f66e5d Will Deacon  2014-02-21  257  	prefetchw(ptr);
c32ffce0f66e5d Will Deacon  2014-02-21  258  
2523c67bb6962f Will Deacon  2013-10-09  259  	__asm__ __volatile__(
2523c67bb6962f Will Deacon  2013-10-09 @260  "1:	ldrexd		%1, %H1, [%3]\n"
2523c67bb6962f Will Deacon  2013-10-09  261  "	teq		%1, %4\n"
2523c67bb6962f Will Deacon  2013-10-09  262  "	teqeq		%H1, %H4\n"
2523c67bb6962f Will Deacon  2013-10-09  263  "	bne		2f\n"
2523c67bb6962f Will Deacon  2013-10-09  264  "	strexd		%0, %5, %H5, [%3]\n"
2523c67bb6962f Will Deacon  2013-10-09  265  "	teq		%0, #0\n"
2523c67bb6962f Will Deacon  2013-10-09  266  "	bne		1b\n"
2523c67bb6962f Will Deacon  2013-10-09  267  "2:"
2523c67bb6962f Will Deacon  2013-10-09  268  	: "=&r" (res), "=&r" (oldval), "+Qo" (*ptr)
2523c67bb6962f Will Deacon  2013-10-09  269  	: "r" (ptr), "r" (old), "r" (new)
2523c67bb6962f Will Deacon  2013-10-09  270  	: "cc");
2523c67bb6962f Will Deacon  2013-10-09  271  
2523c67bb6962f Will Deacon  2013-10-09  272  	return oldval;
2523c67bb6962f Will Deacon  2013-10-09  273  }
2523c67bb6962f Will Deacon  2013-10-09  274  

--
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki

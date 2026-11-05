Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=192.198.163.8
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793878599;
	b=LU4Lw8iw3L4t8K/n9Hh6UJocvA+pzDOKA0VqDcJycGal9N9qVKv7jP40LTqCwmsDG66c
	 GWerN5hzcQ+OcZNSUwp/UMiVhb4fXgnfGvP3sq8ArzqS60SepQ0IEOYh8eqyhMw+WdAHb
	 xuhmdYlauENK5eAJsb4pjzkK9ziARyy8yFo+zbPd/4qvbxWMXT6dcmpey5FJuaTVwiTPy
	 G7GetQSk5HEVd1DPBc2+4IddUJAVrFzwgoeYeBH4TsiBk2Nm6Ji/RB48GKXb6p72Ie8Mm
	 ZLf3qzjHDrsWGIxEZth9e/Mbx6UQd/vShHRA42fUoWDV12vA+zsCez3IUmJSNvEmu1w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793878599;
	h=DMARC-Filter:DKIM-Signature:X-CSE-ConnectionGUID:X-CSE-MsgGUID:
	 X-IronPort-AV:X-IronPort-AV:Received:X-CSE-ConnectionGUID:
	 X-CSE-MsgGUID:X-ExtLoop1:X-IronPort-AV:Received:Received:Date:From:To:
	 Cc:Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=30J4sbOlYJiNq7Z4tRszcjWu8hBcWrg7tEn3jlctPwo=;
	b=xRxzWa8Xy4evAl6NaL+mYks4IQacTnLfihp+tzxY8uHo+NLYRbz3tSNSLnEL+1FfvDD2
	 D3UZh7Sdoe6MocHg6nC5GUObrjQ/GPDZebN/rvGlBt+1pRd49aXzeOiCNfAVhObDYPjqo
	 SYF5bSg2fqmzfE6lfpcNInuPiYYpxbPm5jQMqdiSoPLRyOvQtnFWh3lLz86ILih1SIJts
	 zAyaf9Iz+mUIYRg/rSH7RZB2uaEGoZgCQ8tPkFM8HvoH9nbKCfxaFijqflQL51ChPlssy
	 7VDNqq3k9XuUeQNw96pJK2OJHqW/ogIy4nTJ9Ufw8pEGM3hW82pHdNSrea78h3Z3XpQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=intel.com;
	spf=pass smtp.mailfrom=intel.com;
	dkim=pass header.d=intel.com header.i=@intel.com header.a=rsa-sha256 header.s=Intel header.b=kH6kTpAi;
	arc=none smtp.remote-ip=192.198.163.8
Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.8])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79418606A336;
	Thu,  5 Nov 2026 11:36:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 79418606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=intel.com header.i=@intel.com header.a=rsa-sha256 header.s=Intel header.b=kH6kTpAi
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1793878598; x=1825414598;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=J9dOmPMshDIpYmZ/TrqPMjz7mHsp3Z6+Ou1qHQ88q2c=;
  b=kH6kTpAiQCWPXNnHfol4Ir8+s9VJjZqKUrEiOYYXZ519D9v6B5xP2gry
   GnxiwbeLFhRczydH6mZJ0OLOiGGGZE6rGnuWsdi7YptLDmfnzWYK9ipH0
   dFC+58sXrURL/5et1b81u3MYRwTIazl4W9H6PFyG6JrBjGDynR8P86946
   XGW7UEKjEwT0v0iPok/BKikScign00RZapSIvNNIiIqAoLcjFjvBcwcNF
   mL/HcsTXXDUec0Erc9ynncQVAqW6Z3TJ/1Z9sXlIVcBTPVZLkkuPAbbCG
   vltsW6FpoPg9oXfRHm1xluCStSwpy0jt6Dfl66lBwsO3byRFQOjk4dw6n
   g==;
X-CSE-ConnectionGUID: cQ8hzN4ESnqlamJQ6T0ujw==
X-CSE-MsgGUID: KjYgmGU8SNG9TKQz2y0m6w==
X-IronPort-AV: E=McAfee;i="6800,10657,11956"; a="2547422"
X-IronPort-AV: E=Sophos;i="6.27,197,1787036400"; 
   d="scan'208";a="2547422"
Received: from fmviesa003.fm.intel.com ([10.60.135.143])
  by fmvoesa102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 05 Nov 2026 03:36:37 -0800
X-CSE-ConnectionGUID: NU49M+y7SoqJQQ7rq8Z1Cw==
X-CSE-MsgGUID: /gbM1bnkQwynnPU6B2caeg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.27,197,1787036400"; 
   d="scan'208";a="7163862"
Received: from lkp-server01.sh.intel.com (HELO 0caa9d2d175c) ([10.239.97.150])
  by fmviesa003.fm.intel.com with ESMTP; 05 Nov 2026 03:36:29 -0800
Received: from kbuild by 0caa9d2d175c with local (Exim 4.98.2)
	(envelope-from <lkp@intel.com>)
	id 1xOvlZ-00000000m7v-0S9w;
	Thu, 05 Nov 2026 11:36:25 +0000
Date: Thu, 5 Nov 2026 19:35:46 +0800
From: kernel test robot <lkp@intel.com>
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: oe-kbuild-all@lists.linux.dev, Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <chris.mason@fusionio.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org, linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org, kexec@lists.infradead.org,
	linux-pci@vger.kernel.org
Subject: Re: [PATCH RESEND v2 01/51] alloc_tag: don't remove /proc/allocinfo
 under the codetag module lock
Message-ID: <202611051923.pLSSWWkA-lkp@intel.com>
References: <20261104-work-procfs-bugfixes-v2-1-021c84d852e0@kernel.org>
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
In-Reply-To: <20261104-work-procfs-bugfixes-v2-1-021c84d852e0@kernel.org>

Hi Christian,

kernel test robot noticed the following build warnings:

[auto build test WARNING on 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4]

url:    https://github.com/intel-lab-lkp/linux/commits/Christian-Brauner/alloc_tag-don-t-remove-proc-allocinfo-under-the-codetag-module-lock/20261104-200606
base:   6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
patch link:    https://lore.kernel.org/r/20261104-work-procfs-bugfixes-v2-1-021c84d852e0%40kernel.org
patch subject: [PATCH RESEND v2 01/51] alloc_tag: don't remove /proc/allocinfo under the codetag module lock
config: sh-randconfig-1001-20261105 (https://download.01.org/0day-ci/archive/20261105/202611051923.pLSSWWkA-lkp@intel.com/config)
compiler: sh4-linux-gcc (GCC) 16.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20261105/202611051923.pLSSWWkA-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202611051923.pLSSWWkA-lkp@intel.com/

All warnings (new ones prefixed by >>):

>> mm/alloc_tag.c:620:13: warning: 'shutdown_mem_profiling_async' defined but not used [-Wunused-function]
     620 | static void shutdown_mem_profiling_async(void)
         |             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~


vim +/shutdown_mem_profiling_async +620 mm/alloc_tag.c

   613	
   614	/*
   615	 * A module's tags are reserved with the codetag module lock held for
   616	 * writing, and a reader of /proc/allocinfo takes that lock with the entry
   617	 * pinned. Removing the entry there would wait for that reader for good, so
   618	 * let a work item do it.
   619	 */
 > 620	static void shutdown_mem_profiling_async(void)
   621	{
   622		if (!mem_profiling_support)
   623			return;
   624		shutdown_mem_profiling(false);
   625		schedule_work(&remove_allocinfo_work);
   626	}
   627	

--
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki

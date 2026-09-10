Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A02537B021
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 10:49:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789037343; cv=none; b=u6vLLOTEZOu/+fkjPmXhSqw9KmAMQi/AmP4Ok7lhyyXS+Fa9afED+tKVynI8TsGk27LyD1ZYIV4HKpJJV+zebpbAtMWn8JdAyenoZfo/5HwnhrlAtzJFaTFh1TGZeeYGkRfTpDvn/4ZRD5BMg6QgR6dI+kMFrg7dMvyfs8Qz4l4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789037343; c=relaxed/simple;
	bh=JJRZ161sCXODMCLQwhz+RJmDkmRR+Bni1QWwkUJjKBg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=dD7MxgFMPyq5rrMUcv1iHes0l5Ls+vs9UAGiy9MGVgiz9Rj26qCz93aqAxQLPbd1+fPEXG+kyPSkelO1sCI1RuuNyijAdxLl8oXcalb25aZNCjrlKidPwQNUn87B2yHffy26sWeq0XrJWvnzlVH8WrvK4t1Bz4qNM/C71R6G/pQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=kTshgnee; arc=none smtp.client-ip=198.175.65.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="kTshgnee"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1789037340; x=1820573340;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=JJRZ161sCXODMCLQwhz+RJmDkmRR+Bni1QWwkUJjKBg=;
  b=kTshgnee1tBXFKb3cPp0a/uugCiNlxJTPQYRdS96t6yNyecYzmY+4/bH
   TctH0KpzG9n/vVSQh/+YnZ4UtxZ3zdJcJF64DyXB79/1MRdIC/efMN5vm
   nRfF0MhZWU3y2vIUkZmRkR8Nvt1HYmtGRU8YhSLm4Vd1yWaAgHw4mk0bK
   iqivoMmBZrJ7ODIgZAAcBUhcuoO1LssvqSgmdGGetlxCvpgHjflC/ciHn
   3AWQdrxsUcn88aXMlwZp+UB4IUQDciOUnEZ63JhtcxK+CTgdQMCI0GIoy
   HLSJE6JPOLNriJVCo3e0h0huZ0KGBYW9ZHV/QnctWDxk1p9sSvqsiZZ8a
   g==;
X-CSE-ConnectionGUID: 8bVLfKLpRzqGnDWUixN6YQ==
X-CSE-MsgGUID: GCZWU25iRCyYJxHB9U3eNw==
X-IronPort-AV: E=McAfee;i="6800,10657,11900"; a="93174788"
X-IronPort-AV: E=Sophos;i="6.27,95,1787036400"; 
   d="scan'208";a="93174788"
Received: from orviesa001.jf.intel.com ([10.64.159.141])
  by orvoesa107.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 10 Sep 2026 03:49:00 -0700
X-CSE-ConnectionGUID: q026NSHmSly2AjvQqqBh9g==
X-CSE-MsgGUID: f6/H3fdqSRO5dbk4W8SphA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.27,95,1787036400"; 
   d="scan'208";a="309844487"
Received: from lkp-server01.sh.intel.com (HELO a3e91e2cf319) ([10.239.97.150])
  by orviesa001.jf.intel.com with ESMTP; 10 Sep 2026 03:48:58 -0700
Received: from kbuild by a3e91e2cf319 with local (Exim 4.98.2)
	(envelope-from <lkp@intel.com>)
	id 1x4cKt-000000001iB-3mUv;
	Thu, 10 Sep 2026 10:48:55 +0000
Date: Thu, 10 Sep 2026 18:48:10 +0800
From: kernel test robot <lkp@intel.com>
To: Scott Mayhew <smayhew@redhat.com>, trondmy@kernel.org, anna@kernel.org
Cc: oe-kbuild-all@lists.linux.dev, hch@infradead.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs: split up block layout and SCSI layout support
Message-ID: <202609101831.BgyuWw1E-lkp@intel.com>
References: <20260904172627.1347637-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260904172627.1347637-1-smayhew@redhat.com>

Hi Scott,

kernel test robot noticed the following build errors:

[auto build test ERROR on trondmy-nfs/linux-next]
[also build test ERROR on linus/master v7.3-rc2 next-20260909]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch#_base_tree_information]

url:    https://github.com/intel-lab-lkp/linux/commits/Scott-Mayhew/nfs-split-up-block-layout-and-SCSI-layout-support/20260904-132627
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
patch link:    https://lore.kernel.org/r/20260904172627.1347637-1-smayhew%40redhat.com
patch subject: [PATCH v2] nfs: split up block layout and SCSI layout support
config: x86_64-randconfig-122-20260910 (https://download.01.org/0day-ci/archive/20260910/202609101831.BgyuWw1E-lkp@intel.com/config)
compiler: gcc-14 (Debian 14.2.0-19) 14.2.0
sparse: v0.6.5-rc1
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20260910/202609101831.BgyuWw1E-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202609101831.BgyuWw1E-lkp@intel.com/

All errors (new ones prefixed by >>, old ones prefixed by <<):

>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'bdev_file_open_by_path' undefined!
>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'submit_bio' undefined!
>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'bio_put' undefined!
>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'bio_add_page' undefined!
>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'file_bdev' undefined!
>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'bio_alloc_bioset' undefined!
>> ERROR: modpost: fs/nfs/blocklayout/blocklayoutdriver.ko: symbol 'fs_bio_set' undefined!

--
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki

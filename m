Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09F10C433EF
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Mar 2022 02:04:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242448AbiCYCGZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Mar 2022 22:06:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42436 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233751AbiCYCGY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2022 22:06:24 -0400
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BBE446D3B3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Mar 2022 19:04:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1648173891; x=1679709891;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=agHD+Paz4Jln46JJddZwhukY10qyx004YR+R0qs2Jlg=;
  b=nNyqUKWHZfwXC79cWSrWv1CmWIPGhgQJw4V70taZfJX0DyCzS+gAHGyU
   0Y3p6IwVMWvu586mwcXYqLU8KBNrropYPCXDB3RdsWDKWRbqAwHHiZBc7
   ValXaw7JmCtfdGmf1npjGp0Ky76NDsu5ND1WukhBKzan0TslsfYSPmoxZ
   r3PC8X0knblvOV+hT7gcinTNdYVIwuaAypvGvn94WDq2ijqEzYC/Yw+RW
   YioFP5Kx5e5wN8XYg/wBMTfjHSNiOoN6mPYecXDfOy/xb4iq1SJYkR0If
   gZTrc/+oC8UdagL6lk+sKEedIgYgn7pcaxAc7xom9csdDoyiuQxDZSREq
   Q==;
X-IronPort-AV: E=McAfee;i="6200,9189,10296"; a="258727181"
X-IronPort-AV: E=Sophos;i="5.90,209,1643702400"; 
   d="scan'208";a="258727181"
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 24 Mar 2022 19:04:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.90,209,1643702400"; 
   d="scan'208";a="718053151"
Received: from lkp-server02.sh.intel.com (HELO 89b41b6ae01c) ([10.239.97.151])
  by orsmga005.jf.intel.com with ESMTP; 24 Mar 2022 19:04:33 -0700
Received: from kbuild by 89b41b6ae01c with local (Exim 4.92)
        (envelope-from <lkp@intel.com>)
        id 1nXZJZ-000Lf7-1h; Fri, 25 Mar 2022 02:04:33 +0000
Date:   Fri, 25 Mar 2022 10:03:36 +0800
From:   kernel test robot <lkp@intel.com>
To:     trondmy@kernel.org, linux-nfs@vger.kernel.org
Cc:     kbuild-all@lists.01.org
Subject: Re: [PATCH 1/2] SUNRPC: Do not dereference non-socket transports in
 sysfs
Message-ID: <202203250924.8HsqSPwP-lkp@intel.com>
References: <20220324213345.5833-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220324213345.5833-1-trondmy@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

I love your patch! Perhaps something to improve:

[auto build test WARNING on trondmy-nfs/linux-next]
[also build test WARNING on v5.17 next-20220324]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/trondmy-kernel-org/SUNRPC-Do-not-dereference-non-socket-transports-in-sysfs/20220325-054144
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
config: x86_64-randconfig-c002 (https://download.01.org/0day-ci/archive/20220325/202203250924.8HsqSPwP-lkp@intel.com/config)
compiler: gcc-9 (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>


cocci warnings: (new ones prefixed by >>)
>> net/sunrpc/sysfs.c:123:2-3: Unneeded semicolon

Please review and possibly fold the followup patch.

-- 
0-DAY CI Kernel Test Service
https://01.org/lkp

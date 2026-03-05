Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5C4133F374;
	Thu,  5 Mar 2026 10:13:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772705633; cv=none; b=LA3xzZQivWog45/YRJgNZ5nPAEQry1gcz0CXuEVbvtCa+/GwdoNlbpKXCo4RYlmmyTkJ4LB2N/PzgA6AnMjNrZ1ttwl1gvJrvu0aZdhrMHFNN1iVSws2SZHeltlvTdYiMmV0zu7Ed72LC6S4z1B26g7UCE+4LMOR/U8T57fwKpE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772705633; c=relaxed/simple;
	bh=os8pElF8hPySTMJ5OPZITsFHgDhyLLsZZ4pcbD3N9g0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=p0AIVdqYbw1pj1ZZ0Iro1dzXOfu+aMzhR5L8CkZ+z77WxUx/HWNw9NZ4QpFvTJAXv1kJE2fU9HXngG6VxKxeYYr4Szno+Xj7AYJs/QXLU8ni45oQ20+ie8vBizw2vsOWmshxQjCtlEnmsvzy0GE+1sogQWcrcPUWgan3aBJuMo0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=mcZdt4c9; arc=none smtp.client-ip=198.175.65.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="mcZdt4c9"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1772705632; x=1804241632;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=os8pElF8hPySTMJ5OPZITsFHgDhyLLsZZ4pcbD3N9g0=;
  b=mcZdt4c9THKxnvD+u9bqzG8hmJxx7y+dsBUEyDD4bPzmQxmcuC+5aV98
   rx9uhfSO99Hhln8O5ZF4tcRYx6HzfxUsP9jReAqOrknTk7t+ekcwCaY8t
   fTP1mwEr2UiYbQXoZL3stHvwAkd8xEbBoDKaEz116zMcFYasKXXenKupG
   QeLRZ1vE7ur6ykkGgJp7wxJqPROLP0YmAn/9zaplKONfPeuxDNN9U9C3t
   xNKXEfWiax3H/v4jRK2hjTkC78mFJUMBYO1LI5bT7BQcGmKkmEQkszzPw
   VEyhxNuSWOW0Wg9BLh/fOvQnc/Ibol+6jAlguq/8zFnqW7PLLWzUPWvxs
   Q==;
X-CSE-ConnectionGUID: FKaab1vJRcuYqMzke0iipg==
X-CSE-MsgGUID: hskquXzkRxKzK7ft9ALD8w==
X-IronPort-AV: E=McAfee;i="6800,10657,11719"; a="77391129"
X-IronPort-AV: E=Sophos;i="6.23,102,1770624000"; 
   d="scan'208";a="77391129"
Received: from orviesa002.jf.intel.com ([10.64.159.142])
  by orvoesa107.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 05 Mar 2026 02:13:52 -0800
X-CSE-ConnectionGUID: nICofMrEQPe2MvR9s8A7Xw==
X-CSE-MsgGUID: Zmo+veC5TJWOCqBPQ7Aaew==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.23,102,1770624000"; 
   d="scan'208";a="249102013"
Received: from lkp-server01.sh.intel.com (HELO cadc4577a874) ([10.239.97.150])
  by orviesa002.jf.intel.com with ESMTP; 05 Mar 2026 02:13:49 -0800
Received: from kbuild by cadc4577a874 with local (Exim 4.98.2)
	(envelope-from <lkp@intel.com>)
	id 1vy5iD-000000000Sw-0g4v;
	Thu, 05 Mar 2026 10:13:45 +0000
Date: Thu, 5 Mar 2026 18:13:09 +0800
From: kernel test robot <lkp@intel.com>
To: alistair23@gmail.com, chuck.lever@oracle.com, hare@kernel.org,
	kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
Cc: oe-kbuild-all@lists.linux.dev, kbusch@kernel.org, axboe@kernel.dk,
	hch@lst.de, sagi@grimberg.me, kch@nvidia.com, hare@suse.de,
	alistair23@gmail.com, Alistair Francis <alistair.francis@wdc.com>
Subject: Re: [PATCH v7 4/5] nvme-tcp: Support KeyUpdate
Message-ID: <202603051846.RCN7R5uj-lkp@intel.com>
References: <20260304053500.590630-5-alistair.francis@wdc.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260304053500.590630-5-alistair.francis@wdc.com>

Hi,

kernel test robot noticed the following build errors:

[auto build test ERROR on trondmy-nfs/linux-next]
[also build test ERROR on net/main net-next/main linus/master v7.0-rc2 next-20260304]
[cannot apply to linux-nvme/for-next horms-ipvs/master]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch#_base_tree_information]

url:    https://github.com/intel-lab-lkp/linux/commits/alistair23-gmail-com/net-handshake-Store-the-key-serial-number-on-completion/20260304-134148
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
patch link:    https://lore.kernel.org/r/20260304053500.590630-5-alistair.francis%40wdc.com
patch subject: [PATCH v7 4/5] nvme-tcp: Support KeyUpdate
config: sh-allmodconfig (https://download.01.org/0day-ci/archive/20260305/202603051846.RCN7R5uj-lkp@intel.com/config)
compiler: sh4-linux-gcc (GCC) 15.2.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20260305/202603051846.RCN7R5uj-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202603051846.RCN7R5uj-lkp@intel.com/

All errors (new ones prefixed by >>):

   drivers/nvme/host/tcp.c: In function 'nvme_tcp_try_recv':
>> drivers/nvme/host/tcp.c:1429:31: error: 'const struct proto_ops' has no member named 'read_sock_cmsg'; did you mean 'read_sock'?
    1429 |         consumed = sock->ops->read_sock_cmsg(sk, &rd_desc, nvme_tcp_recv_skb,
         |                               ^~~~~~~~~~~~~~
         |                               read_sock


vim +1429 drivers/nvme/host/tcp.c

  1417	
  1418	static int nvme_tcp_try_recv(struct nvme_tcp_queue *queue)
  1419	{
  1420		struct socket *sock = queue->sock;
  1421		struct sock *sk = sock->sk;
  1422		read_descriptor_t rd_desc;
  1423		int consumed;
  1424	
  1425		rd_desc.arg.data = queue;
  1426		rd_desc.count = 1;
  1427		lock_sock(sk);
  1428		queue->nr_cqe = 0;
> 1429		consumed = sock->ops->read_sock_cmsg(sk, &rd_desc, nvme_tcp_recv_skb,
  1430						     nvme_tcp_recv_cmsg);
  1431		release_sock(sk);
  1432		return consumed == -EAGAIN ? 0 : consumed;
  1433	}
  1434	

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki

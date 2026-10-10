Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0597434A79D
	for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 04:33:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.8
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791606826; cv=none; b=ftpkXtg+3F2+uohsEH0sZ+0zj4hs9QUUvEdkLOvlcU8c9KwPcEe7kErOJF0ypsK84j9arUkeEkmfaA9lxeMBYwsK8KEZ2/YhTXTUh9wsH1p6mvvM22/t0ZNG94FIOCzffG4iSubkiI5+DkmcFb1Je/0+aRl+XnpW7uIVG3a5dyU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791606826; c=relaxed/simple;
	bh=Ovuopj3ancVGepJBxH0p4IIedmQOa7Ldw3S6CpDi7EY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=r7TIwedcLnEIUKlFSXDuPYYqiHieNYiIc0DYm+yi265iGPYF1OEtLMVxPy47gkbgA7OG4hx/9fbvu+YjSKbKC/AAuXsIrg78to0wWZEjH8gVrFBT/cbFieZ2LgqXkQ9sRxsDQ+yLVqargZNFfoJGOW/de3yrJ7ABPJ9C+tNtrvw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=dV4mTlnG; arc=none smtp.client-ip=192.198.163.8
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="dV4mTlnG"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1791606826; x=1823142826;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=Ovuopj3ancVGepJBxH0p4IIedmQOa7Ldw3S6CpDi7EY=;
  b=dV4mTlnGAVrboTuYbVk0bDJVQrZoxWCF+aEHvibBIRQ02v4kdSMeAvCw
   /V/bf1HkQ/Hyy+i8PFDX4RNr3bM7aSUFUy2ZOVDFXCjDQkYEPCzsXIt/1
   H3XiTqr+Wy1vD2pMk7jTlYTc+Nz+y+oUwBM0pYffUzfx+jWRR1FwXc6Qb
   GI7n5xM9ui6kP9BtPhC8IM0AoqLcJQo8K90e4uLgNiQnC/PheK765niR0
   F63JhX9lhVfB4cooCuu6DMESsfOqE/aziYR5Dfs1bKqE2ggogfy+t6Hjl
   EFJALbtS3lbKYGr6XchgHp8Pzpk/j/SiTY8R3KGvZb9cs7LDlt77rE54G
   g==;
X-CSE-ConnectionGUID: Vkndq5B9R7mSYHZaTV/pxQ==
X-CSE-MsgGUID: LU6irICKSumFe3jojy+lDQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11930"; a="297546"
X-IronPort-AV: E=Sophos;i="6.27,149,1787036400"; 
   d="scan'208";a="297546"
Received: from fmviesa007.fm.intel.com ([10.60.135.147])
  by fmvoesa102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 09 Oct 2026 21:33:45 -0700
X-CSE-ConnectionGUID: ADYKFu3vTliZiSZEw0jAvQ==
X-CSE-MsgGUID: AFU2TKwgRcOjP5T/Iz0GlQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.27,149,1787036400"; 
   d="scan'208";a="802521"
Received: from lkp-server01.sh.intel.com (HELO 0caa9d2d175c) ([10.239.97.150])
  by fmviesa007.fm.intel.com with ESMTP; 09 Oct 2026 21:33:42 -0700
Received: from kbuild by 0caa9d2d175c with local (Exim 4.98.2)
	(envelope-from <lkp@intel.com>)
	id 1xFOmB-000000006U7-1mFK;
	Sat, 10 Oct 2026 04:33:39 +0000
Date: Sat, 10 Oct 2026 12:33:03 +0800
From: kernel test robot <lkp@intel.com>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: oe-kbuild-all@lists.linux.dev, linux-nfs@vger.kernel.org,
	syzbot+9c7b9c5f6dd1d470b605@syzkaller.appspotmail.com
Subject: Re: [PATCH v1] NFSD: Don't start nfsd threads from a pool_threads
 write
Message-ID: <202610101235.HaenlCPb-lkp@intel.com>
References: <20261009144017.1284586-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261009144017.1284586-1-cel@kernel.org>

Hi Chuck,

kernel test robot noticed the following build errors:

[auto build test ERROR on brauner-vfs/vfs.all]
[also build test ERROR on linus/master v7.3-rc6 next-20261008]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch#_base_tree_information]

url:    https://github.com/intel-lab-lkp/linux/commits/Chuck-Lever/NFSD-Don-t-start-nfsd-threads-from-a-pool_threads-write/20261009-104017
base:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git vfs.all
patch link:    https://lore.kernel.org/r/20261009144017.1284586-1-cel%40kernel.org
patch subject: [PATCH v1] NFSD: Don't start nfsd threads from a pool_threads write
config: parisc64-defconfig (https://download.01.org/0day-ci/archive/20261010/202610101235.HaenlCPb-lkp@intel.com/config)
compiler: hppa64-linux-gcc (GCC) 16.1.0
reproduce (this is a W=1 build): (https://download.01.org/0day-ci/archive/20261010/202610101235.HaenlCPb-lkp@intel.com/reproduce)

If you fix the issue in a separate patch/commit (i.e. not just a new version of
the same patch/commit), kindly add following tags
| Reported-by: kernel test robot <lkp@intel.com>
| Closes: https://lore.kernel.org/oe-kbuild-all/202610101235.HaenlCPb-lkp@intel.com/

All errors (new ones prefixed by >>):

   In file included from include/linux/log2.h:12,
                    from include/asm-generic/div64.h:55,
                    from ./arch/parisc/include/generated/asm/div64.h:1,
                    from include/linux/math.h:6,
                    from include/linux/math64.h:6,
                    from include/linux/time64.h:5,
                    from include/linux/restart_block.h:9,
                    from include/linux/thread_info.h:14,
                    from include/asm-generic/preempt.h:5,
                    from ./arch/parisc/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:107,
                    from include/linux/spinlock.h:56,
                    from include/linux/mmzone.h:8,
                    from include/linux/gfp.h:7,
                    from include/linux/slab.h:17,
                    from fs/nfsd/nfsctl.c:8:
   fs/nfsd/nfsctl.c: In function 'write_pool_threads':
>> fs/nfsd/nfsctl.c:504:48: error: 'nn' undeclared (first use in this function)
     504 |         if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
         |                                                ^~
   include/linux/bitops.h:44:44: note: in definition of macro 'bitop'
      44 |           __builtin_constant_p((uintptr_t)(addr) != (uintptr_t)NULL) && \
         |                                            ^~~~
   fs/nfsd/nfsctl.c:504:25: note: in expansion of macro 'test_bit'
     504 |         if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
         |                         ^~~~~~~~
   fs/nfsd/nfsctl.c:504:48: note: each undeclared identifier is reported only once for each function it appears in
   include/linux/bitops.h:44:44: note: in definition of macro 'bitop'
      44 |           __builtin_constant_p((uintptr_t)(addr) != (uintptr_t)NULL) && \
         |                                            ^~~~
   fs/nfsd/nfsctl.c:504:25: note: in expansion of macro 'test_bit'
     504 |         if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
         |                         ^~~~~~~~


vim +/nn +504 fs/nfsd/nfsctl.c

   449	
   450	/*
   451	 * write_pool_threads - Set or report the configured number of threads per pool
   452	 *
   453	 * Input:
   454	 *			buf:		ignored
   455	 *			size:		zero
   456	 *
   457	 * OR
   458	 *
   459	 * Input:
   460	 *			buf:		C string containing whitespace-
   461	 *					separated unsigned integer values
   462	 *					representing the number of NFSD
   463	 *					threads to start in each pool
   464	 *			size:		non-zero length of C string in @buf
   465	 * Output:
   466	 *	On success:	passed-in buffer filled with '\n'-terminated C
   467	 *			string containing integer values representing the
   468	 *			configured number of NFSD threads in each pool;
   469	 *			return code is the size in bytes of the string
   470	 *	On error:	return code is zero or a negative errno value
   471	 */
   472	static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
   473	{
   474		/* if size > 0, look for an array of number of threads per node
   475		 * and apply them  then write out number of threads per node as reply
   476		 */
   477		char *mesg = buf;
   478		int i;
   479		int rv;
   480		int len;
   481		int npools;
   482		int *nthreads;
   483		struct net *net = netns(file);
   484	
   485		mutex_lock(&nfsd_mutex);
   486		npools = nfsd_nrpools(net);
   487		if (npools == 0) {
   488			/*
   489			 * NFS is shut down.  The admin can start it by
   490			 * writing to the threads file but NOT the pool_threads
   491			 * file, sorry.  Report zero threads.
   492			 */
   493			mutex_unlock(&nfsd_mutex);
   494			strcpy(buf, "0\n");
   495			return strlen(buf);
   496		}
   497	
   498		nthreads = kzalloc_objs(int, npools);
   499		rv = -ENOMEM;
   500		if (nthreads == NULL)
   501			goto out_free;
   502	
   503		/* Threads started now would run without NFSv4 state. */
 > 504		if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
   505			for (i = 0; i < npools; i++) {
   506				rv = get_int(&mesg, &nthreads[i]);
   507				if (rv == -ENOENT)
   508					break;		/* fewer numbers than pools */
   509				if (rv)
   510					goto out_free;	/* syntax error */
   511				rv = -EINVAL;
   512				if (nthreads[i] < 0)
   513					goto out_free;
   514				trace_nfsd_ctl_pool_threads(net, i, nthreads[i]);
   515			}
   516	
   517			/*
   518			 * There must always be a thread in pool 0; the admin
   519			 * can't shut down NFS completely using pool_threads.
   520			 */
   521			if (nthreads[0] == 0)
   522				nthreads[0] = 1;
   523	
   524			rv = nfsd_set_nrthreads(i, nthreads, net);
   525			if (rv)
   526				goto out_free;
   527		}
   528	
   529		rv = nfsd_get_nrthreads(npools, nthreads, net);
   530		if (rv)
   531			goto out_free;
   532	
   533		mesg = buf;
   534		size = SIMPLE_TRANSACTION_LIMIT;
   535		for (i = 0; i < npools && size > 0; i++) {
   536			snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
   537			len = strlen(mesg);
   538			size -= len;
   539			mesg += len;
   540		}
   541		rv = mesg - buf;
   542	out_free:
   543		kfree(nthreads);
   544		mutex_unlock(&nfsd_mutex);
   545		return rv;
   546	}
   547	

--
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests/wiki

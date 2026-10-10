Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB2E9366057;
	Sat, 10 Oct 2026 17:57:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791655072; cv=none; b=F0Cf79Kz7VP2vpBXe1QysZ+iSXsyzO2/iwd4P+JxFAgwEaqQBqtsaIuKg3DSe/gdHaEFhK/5RcfhXVWuldLuXTLRvyxFUFlwy/qKZu7IrlVte44EsIv+pDXl20GH3/nPbIgNUiNoARMCpywLMUYsSU/txFirO+ZX0goUsxNs6m4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791655072; c=relaxed/simple;
	bh=X3xpVe605EVrK4lzrq61AKRbB8xfwGDJGB/Im9KGh8Y=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=ZownkPxBQXxIakIV/XmFgJy7SyIPNl4ZLGj1vUghD+P9fGf8Ro0xeY6WUgsQwps9oVeVFjC62Y8v9p09SKxYR3wKgh8YlwhnAWD0mvrVZuMOStK5xjmbLe9NTz4Vric0JZkIoq1yB8JcdtS2L9CTb8n8CI2vOVHWgt5XgQAEvR0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UckC80IW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UckC80IW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D04061F00898;
	Sat, 10 Oct 2026 17:57:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791655070;
	bh=HszBDE6jNNiclHOKtkCyXEmnlnOaT4IqaBk9y96J430=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=UckC80IWgtnGDov3aFPXZktL4PzoxMV+FtuUs5L01ggiRu7zcDTXkcZki4o8zGCC1
	 YvlwSmr9YZcne1cT08gu56Rc/NrQqDk0Qcdj6G0iE1tZ9JFqWyNrdVCc1s+IH0perz
	 AT7TRrKNNQnMjHYQR2puStlE3nwFr1cqsXNwm9s7phd7ZWe8nNCmXgfWaIT9Qlm8l7
	 JD3qDBydSiPfuuZOYcKxWpMpJHdgSSZyvMr6viAmMxlONrs6ICygnLQi76XsyfRnl8
	 3Pi5yLcAXBgfMSLeV99YqFWvxtoEdA4PfLNtjMKQOpzM0vnpTBBq0nh4KLI4x+GBup
	 ZvZ1LBixILVdw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DD0A4F40066;
	Sat, 10 Oct 2026 13:57:48 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 10 Oct 2026 13:57:48 -0400
X-ME-Sender: <xms:nHzKaodSLQmCIQcflvLGNM5UgAproI7aiCJt2KQa5TX5RnYkXG9waQ>
    <xme:nHzKalBBdKLiURZQJ07mVfhAicLMseaXAsJTXmKgGfybJfci77tmnGNbMPFGqvyYu
    tHA8RJf9LfRLt8X_a_oqSRvDm8LNII0LbySlUy5U2-Blap2x5tdqxXE>
X-ME-Proxy-Cause: dmFkZTFs2ifywcvsZLDDpBQyzfQtpn30urVxOOG15C8ksLsvIDAH8kXOXowOMv4dBRT6ZD
    q+/Z7CFze/tr5igvrbnpYsqeGIKmql0h+cmYw9iuR3HnT1nkl67DMadtYaBLxJP3o53zWA
    UNX1lydvnBewfNoTOWF5p+gircqIrAPumH9SGRLdctnO5O45bgBDg+Yn9INeKGtMGDolWT
    HiNY0wIicmwT35Ol5C85OXqrCDHuL7/lO0qyG7Wb0uYAKaw5VU6rObHYo/lKjf2IULs2hI
    10URRC3KkLqWMz+rU9vsVF3Ad/Vh/BdW5gdBKCDgOzK9kFvcrHbW64FMrcDbI7xN4TXBSv
    Hlsz7mnn98v6JFbIEWTP2LJmjfjiY+mbFNl7oUmzKxkwu8OVaHC7pDwCBtQLY0FW/VN845
    ORK9o1WU0ezBl7oNyRSDT8hOBx4FNJ8CHipkmnWbQn9YAVW7uRRMyD+WCTXet5mq1hcxq3
    rHl8b3zvDDCTuwzoMiNddAMOONgq7OjOlOZlUGwREnOfNnlq/C9w088qSwo6Y9jmlKXjyf
    026ELOoXkXyY7oBdaPaJ0HZFNRBsfUbCELpWO6pjPskQtbO/EPBQ2gkYLMoVadxdZDKXn+
    PeP+J6BqeJw9cgOWM0MJid+nIWKvYgEpOehVXVyRlcy277PeSHFLtUy8kRmpE/nwN4wiqY
    MrGaFdQuayr72/lvUznXIDIZZSAYrwAq3upnb99txMYg1NUG8HjwXn2/9AL4vxfYMDXMjX
    4WAvLJ7UuF/hUJwqSMMc3MAOm5DyZFfkY+eWTv7B7lWVV6ftzfjv0y/M2uavyiQq/jDhgR
    TpPn5NISYNKYRFyc2ABO1v5OrHqW//A0Y/Rinli22+HkWgqebZg9aZl1t8+HtK/h8rnw82
    2wh032m9TItoeu9ShtgYFoXUYrJqT6cLOLdMnotBAYFu2jnV/bmWwv9Vz+joMwVsHyhCIG
    o65w6/SPICq0p//y2NrDOPnBWvHMRb14XybaazuBsZzxoRDqqXw
X-ME-Proxy: <xmx:nHzKaufVjNBRk8rVf_LcShyI49hH5MvV0_jJ9RIxhGbOm79OZ7AJfg>
    <xmx:nHzKakyE5E6tyNbis66v5ZGPAcXW6A9CdbGAge9CKJeKJq9jvVOnmA>
    <xmx:nHzKaj_V3jfA6JQRcXI7StSs8pMXHKYs1I_MWzPmjB1takRwlz85oA>
    <xmx:nHzKaixnAGbDS6S3j3nE-26w1rxsZ-9NPHX1qAIN0WP1rtfta9f1Rw>
    <xmx:nHzKarpNi2utm9Nw5vdGkdPn2ti5zLPw5kYMtUEHc8jCT8vYL_2ppdv1>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B3864780FAB; Sat, 10 Oct 2026 13:57:48 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AS-WToHieBv3
Date: Sat, 10 Oct 2026 13:57:27 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "kernel test robot" <lkp@intel.com>, NeilBrown <neilb@ownmail.net>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: oe-kbuild-all@lists.linux.dev, linux-nfs@vger.kernel.org,
 syzbot+9c7b9c5f6dd1d470b605@syzkaller.appspotmail.com
Message-Id: <ba4c784e-6efb-4158-8be6-3ebd781497aa@app.fastmail.com>
In-Reply-To: <202610101235.HaenlCPb-lkp@intel.com>
References: <20261009144017.1284586-1-cel@kernel.org>
 <202610101235.HaenlCPb-lkp@intel.com>
Subject: Re: [PATCH v1] NFSD: Don't start nfsd threads from a pool_threads write
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Oct 10, 2026, at 12:33 AM, kernel test robot wrote:
> Hi Chuck,
>
> kernel test robot noticed the following build errors:
>
> [auto build test ERROR on brauner-vfs/vfs.all]
> [also build test ERROR on linus/master v7.3-rc6 next-20261008]
> [If your patch is applied to the wrong git tree, kindly drop us a note.
> And when submitting patch, we suggest to use '--base' as documented in
> https://git-scm.com/docs/git-format-patch#_base_tree_information]
>
> url:    
> https://github.com/intel-lab-lkp/linux/commits/Chuck-Lever/NFSD-Don-t-start-nfsd-threads-from-a-pool_threads-write/20261009-104017
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git 
> vfs.all
> patch link:    
> https://lore.kernel.org/r/20261009144017.1284586-1-cel%40kernel.org
> patch subject: [PATCH v1] NFSD: Don't start nfsd threads from a 
> pool_threads write
> config: parisc64-defconfig 
> (https://download.01.org/0day-ci/archive/20261010/202610101235.HaenlCPb-lkp@intel.com/config)
> compiler: hppa64-linux-gcc (GCC) 16.1.0
> reproduce (this is a W=1 build): 
> (https://download.01.org/0day-ci/archive/20261010/202610101235.HaenlCPb-lkp@intel.com/reproduce)
>
> If you fix the issue in a separate patch/commit (i.e. not just a new 
> version of
> the same patch/commit), kindly add following tags
> | Reported-by: kernel test robot <lkp@intel.com>
> | Closes: 
> https://lore.kernel.org/oe-kbuild-all/202610101235.HaenlCPb-lkp@intel.com/
>
> All errors (new ones prefixed by >>):
>
>    In file included from include/linux/log2.h:12,
>                     from include/asm-generic/div64.h:55,
>                     from ./arch/parisc/include/generated/asm/div64.h:1,
>                     from include/linux/math.h:6,
>                     from include/linux/math64.h:6,
>                     from include/linux/time64.h:5,
>                     from include/linux/restart_block.h:9,
>                     from include/linux/thread_info.h:14,
>                     from include/asm-generic/preempt.h:5,
>                     from ./arch/parisc/include/generated/asm/preempt.h:1,
>                     from include/linux/preempt.h:107,
>                     from include/linux/spinlock.h:56,
>                     from include/linux/mmzone.h:8,
>                     from include/linux/gfp.h:7,
>                     from include/linux/slab.h:17,
>                     from fs/nfsd/nfsctl.c:8:
>    fs/nfsd/nfsctl.c: In function 'write_pool_threads':
>>> fs/nfsd/nfsctl.c:504:48: error: 'nn' undeclared (first use in this function)
>      504 |         if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
>          |                                                ^~
>    include/linux/bitops.h:44:44: note: in definition of macro 'bitop'
>       44 |           __builtin_constant_p((uintptr_t)(addr) != 
> (uintptr_t)NULL) && \
>          |                                            ^~~~
>    fs/nfsd/nfsctl.c:504:25: note: in expansion of macro 'test_bit'
>      504 |         if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
>          |                         ^~~~~~~~
>    fs/nfsd/nfsctl.c:504:48: note: each undeclared identifier is 
> reported only once for each function it appears in
>    include/linux/bitops.h:44:44: note: in definition of macro 'bitop'
>       44 |           __builtin_constant_p((uintptr_t)(addr) != 
> (uintptr_t)NULL) && \
>          |                                            ^~~~
>    fs/nfsd/nfsctl.c:504:25: note: in expansion of macro 'test_bit'
>      504 |         if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
>          |                         ^~~~~~~~
>
>
> vim +/nn +504 fs/nfsd/nfsctl.c
>
>    449	
>    450	/*
>    451	 * write_pool_threads - Set or report the configured number of 
> threads per pool
>    452	 *
>    453	 * Input:
>    454	 *			buf:		ignored
>    455	 *			size:		zero
>    456	 *
>    457	 * OR
>    458	 *
>    459	 * Input:
>    460	 *			buf:		C string containing whitespace-
>    461	 *					separated unsigned integer values
>    462	 *					representing the number of NFSD
>    463	 *					threads to start in each pool
>    464	 *			size:		non-zero length of C string in @buf
>    465	 * Output:
>    466	 *	On success:	passed-in buffer filled with '\n'-terminated C
>    467	 *			string containing integer values representing the
>    468	 *			configured number of NFSD threads in each pool;
>    469	 *			return code is the size in bytes of the string
>    470	 *	On error:	return code is zero or a negative errno value
>    471	 */
>    472	static ssize_t write_pool_threads(struct file *file, char *buf, 
> size_t size)
>    473	{
>    474		/* if size > 0, look for an array of number of threads per node
>    475		 * and apply them  then write out number of threads per node as 
> reply
>    476		 */
>    477		char *mesg = buf;
>    478		int i;
>    479		int rv;
>    480		int len;
>    481		int npools;
>    482		int *nthreads;
>    483		struct net *net = netns(file);
>    484	
>    485		mutex_lock(&nfsd_mutex);
>    486		npools = nfsd_nrpools(net);
>    487		if (npools == 0) {
>    488			/*
>    489			 * NFS is shut down.  The admin can start it by
>    490			 * writing to the threads file but NOT the pool_threads
>    491			 * file, sorry.  Report zero threads.
>    492			 */
>    493			mutex_unlock(&nfsd_mutex);
>    494			strcpy(buf, "0\n");
>    495			return strlen(buf);
>    496		}
>    497	
>    498		nthreads = kzalloc_objs(int, npools);
>    499		rv = -ENOMEM;
>    500		if (nthreads == NULL)
>    501			goto out_free;
>    502	
>    503		/* Threads started now would run without NFSv4 state. */
>  > 504		if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
>    505			for (i = 0; i < npools; i++) {
>    506				rv = get_int(&mesg, &nthreads[i]);
>    507				if (rv == -ENOENT)
>    508					break;		/* fewer numbers than pools */
>    509				if (rv)
>    510					goto out_free;	/* syntax error */
>    511				rv = -EINVAL;
>    512				if (nthreads[i] < 0)
>    513					goto out_free;
>    514				trace_nfsd_ctl_pool_threads(net, i, nthreads[i]);
>    515			}
>    516	
>    517			/*
>    518			 * There must always be a thread in pool 0; the admin
>    519			 * can't shut down NFS completely using pool_threads.
>    520			 */
>    521			if (nthreads[0] == 0)
>    522				nthreads[0] = 1;
>    523	
>    524			rv = nfsd_set_nrthreads(i, nthreads, net);
>    525			if (rv)
>    526				goto out_free;
>    527		}
>    528	
>    529		rv = nfsd_get_nrthreads(npools, nthreads, net);
>    530		if (rv)
>    531			goto out_free;
>    532	
>    533		mesg = buf;
>    534		size = SIMPLE_TRANSACTION_LIMIT;
>    535		for (i = 0; i < npools && size > 0; i++) {
>    536			snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? 
> '\n' : ' '));
>    537			len = strlen(mesg);
>    538			size -= len;
>    539			mesg += len;
>    540		}
>    541		rv = mesg - buf;
>    542	out_free:
>    543		kfree(nthreads);
>    544		mutex_unlock(&nfsd_mutex);
>    545		return rv;
>    546	}
>    547	
>
> --
> 0-DAY CI Kernel Test Service
> https://github.com/intel/lkp-tests/wiki

The build bot applied this patch to trees that do not include the
work that's pending in the cel/nfsd-testing branch. It applied
cleanly, but those trees are missing the pre-requisite
nfsd-per-net-mutex series from Jeff Layton.

Interestingly, sashiko reported the same failure yesterday, but I
was not able to reproduce it because I didn't realize where it was
trying to apply the patch.

Since this patch is marked Cc: stable, I'll make it easy to backport
by sinking it on my nfsd-testing branch below the pre-requisites and
then adjusting those patches.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Tue, 1 Apr 2008 18:13:27 -0400
Message-ID: <20080401221327.GH21343@fieldses.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local> <20080401210627.GD21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3777@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42281 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbYDAWN3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Apr 2008 18:13:29 -0400
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C59D3777-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 01, 2008 at 02:19:04PM -0700, Anirban Sinha wrote:
> Hi:
> 
> Thanks for responding. 
> 
> 
> >> And the kernel log says:
> >> [13:37:37.766844] nfsd: Could not allocate memory read-ahead cache.
> >
> >What kernel version is this?  
> 
> I am using kernel version 2.6.17.7. 
> 
> 
> > In the latest
> >fs/nfsd/vfs.c:nfsd_racache_init(int cache_size):
> >
> >	raparml = kcalloc(cache_size, sizeof(struct raparms), GFP_KERNEL);
> >
> >	if (!raparml) {
> >		printk(KERN_WARNING
> >			"nfsd: Could not allocate memory read-ahead
> >cache.\n");
> >		return -ENOMEM;
> >	}
> >
> >which is called from fs/nfsd/nfssvc.c:nfsd_svc() as:
> >
> >	error = nfsd_racache_init(2*nrservs);
> >
> >where nrservs is the number of server threads.  How many server threads
> >are you
> >trying to start, and how much memory do you have?
> 
> 
> Yea, I have seen that codebase. The configuration file /etc/init.d/nfs creates 8 nfs threads:
> 
> root:Zeugma:/etc/init.d# ps -A |grep nfs
>  2202 ?        00:00:00 nfsd
>  2203 ?        00:00:00 nfsd
>  2204 ?        00:00:00 nfsd
>  2205 ?        00:00:00 nfsd
>  2206 ?        00:00:00 nfsd
>  2207 ?        00:00:00 nfsd
>  2208 ?        00:00:00 nfsd
>  2209 ?        00:00:00 nfsd
> root:Zeugma:/etc/init.d# free
>              total       used       free     shared    buffers     cached
> Mem:        255372      34352     221020          0       2564      18720
> -/+ buffers/cache:      13068     242304
> Swap:            0          0          0
> 
> 
> The funny thing is that the moment I enable nfsd filesystem, the problem
> seems to go away.

OK, so write_svc() (hence sys_nfsservctl()) is getting garbage.  Hm.
The structure that's passed in to the kernel is:

	struct nfsctl_svc {
		unsigned short svc_port;
		int svc_nthreads;
	};

Is it at all possible that userspace and the kernel could disagree about
the layout of that structure?

Can you play with strace or insert some printk's to figure out what's
going on?

> Can you try and reproduce the problem by disabling nfsd filesystem in your
> system?

I haven't tried yet.

--b.

> 
> #> umount /proc/fs/nfsd
> 
> Ani
> 
> 
> 
> 
> >
> >--b.
> >
> >>
> >> This issue is happening on an intel platform. However, this same
> >operation succeeds on our mips platform (without nfsd filesystem). What
> >is also interesting is that once I turn on /proc/fs/nfsd filesystem on
> >Intel, the issue seems to go away.
> >>
> >> Several weeks back, I reported an issue regarding exportfs -a failure
> >on an already exported filesystem when nfsd FS was not used. It turned
> >out to be a bug in the nfsutils. Did we bump into another bug here? Is
> >there no other option but to turn on nfsd filesystem?
> >>
> >> Thanks for whoever responds to this ...
> >>
> >> Cheers,
> >>
> >> Ani
> >>
> >>
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> >in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html

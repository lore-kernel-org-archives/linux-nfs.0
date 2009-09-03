From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: VM issue causing high CPU loads
Date: Wed, 2 Sep 2009 17:06:42 -0700
Message-ID: <20090902170642.f4381c1d.akpm@linux-foundation.org>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
	<20090824162155.ce323f08.akpm@linux-foundation.org>
	<4A96463E.5080002@corp.free.fr>
	<4A9C34F8.2010307@corp.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ytordjman-CZvJ5kAzflf985uAA1p3mw@public.gmane.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>, mikevs@xs4all.net
To: Yohan <ytordjman-CZvJ5kAzflf985uAA1p3mw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39688 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753872AbZICAHE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 20:07:04 -0400
In-Reply-To: <4A9C34F8.2010307-CZvJ5kAzflf985uAA1p3mw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 31 Aug 2009 22:39:20 +0200
Yohan <ytordjman-CZvJ5kAzflf985uAA1p3mw@public.gmane.org> wrote:

> Yohan wrote:
> > Andrew Morton wrote:
> >> On Mon, 24 Aug 2009 16:23:22 +0200
> >> Yohan <kernel-qqs8qlct+LniQET9NtBuNOUY/dPFsV6l@public.gmane.org> wrote:  
> >>> Hi,
> >>>
> >>>     Is someone have an idea for that :
> >>>
> >>>         http://bugzilla.kernel.org/show_bug.cgi?id=14024
> >>>     
> >> Please generate a kernel profile to work out where all the CPU tie is
> >> being spent.  Documentation/basic_profiling.txt is a starting point.
> >>   
> > I post some new reports, it seems that the problem is in  
> > rpcauth_lookup_credcache ...

Thanks, that helps a lot.

> > for information, this is an imap mail server that mounts ~10 netapp 
> > over ~300 mountpoints..
>     I saw that : http://patchwork.kernel.org/patch/24747/

I wonder what happened with Miquel's patch?

> I did only:
> 
> --- linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-03-23 23:04:09.000000000 +0100
> +++ linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-05-19 16:02:35.000000000 +0200
> @@ -62,8 +62,12 @@ 
>   */
> - #define RPC_CREDCACHE_HASHBITS	4
> + #define RPC_CREDCACHE_HASHBITS	12
> 
> 
> And i test it in prod since sunday: i only have 36% of one core used by 
> system
> versus more than 3 cores used by system in another server that did a 
> drop_caches at morning...
> 

OK, but it's still pretty bad.  Let's tell the NFS guys.

In http://bugzilla.kernel.org/show_bug.cgi?id=14024 we appear to have a
major meltdown caused by the linear search in
rpcauth_lookup_credcache() with Yohan's workload.


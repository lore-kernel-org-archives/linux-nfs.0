From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: PATCH 2 of 4] cpumask: export cpu_online_map and cpu_possible_map
 consistently
Date: Fri, 04 Aug 2006 07:32:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608040730430.16814@montezuma.fsmlabs.com>
References: <1154669759.21040.2353.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030323AbWHDObL@vger.kernel.org>
In-reply-to: <1154669759.21040.2353.camel@hole.melbourne.sgi.com>
To: Greg Banks <gnb@melbourne.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 4 Aug 2006, Greg Banks wrote:

> cpumask: ensure that the cpu_online_map and cpu_possible_map bitmasks,
> and hence all the macros in <linux/cpumask.h> that require them, are
> available to modules for all supported combinations of architecture
> and CONFIG_SMP.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> ---
> 
>  arch/arm/kernel/smp.c           |    2 ++
>  arch/cris/arch-v32/kernel/smp.c |    1 +
>  arch/sh/kernel/smp.c            |    1 +
>  kernel/sched.c                  |    3 +++
>  4 files changed, 7 insertions(+)
> 
> Index: linux-2.6.18-rc2/kernel/sched.c
> ===================================================================
> --- linux-2.6.18-rc2.orig/kernel/sched.c	2006-08-01 17:53:25.000000000 +1000
> +++ linux-2.6.18-rc2/kernel/sched.c	2006-08-02 23:01:20.535457863 +1000
> @@ -4348,7 +4348,10 @@ EXPORT_SYMBOL(cpu_present_map);
>  
>  #ifndef CONFIG_SMP
>  cpumask_t cpu_online_map __read_mostly = CPU_MASK_ALL;
> +EXPORT_SYMBOL_GPL(cpu_online_map);

>  cpumask_t cpu_possible_map;
> +EXPORT_SYMBOL(cpu_possible_map);
>  cpumask_t cpu_online_map;
> +EXPORT_SYMBOL(cpu_online_map);

How come these are of different export types?

Cheers,
	Zwane

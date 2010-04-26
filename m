From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
Date: Mon, 26 Apr 2010 17:04:14 -0400
Message-ID: <1272315854.8984.125.camel@localhost.localdomain>
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net>
	 <20100419131718.GB16918@redhat.com>
	 <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net>
	 <20100421094249.GC30855@redhat.com>
	 <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net>
	 <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net>
	 <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net>
	 <20100425204916.GA12686@redhat.com>
	 <1272284154.4252.34.camel@localhost.localdomain>
	 <4BD5F6C5.8080605@tauceti.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Robert Wimmer <kernel-PAwl83ecUlHR7s880joybQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30787 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab0DZVEQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Apr 2010 17:04:16 -0400
In-Reply-To: <4BD5F6C5.8080605-PAwl83ecUlHR7s880joybQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-04-26 at 22:25 +0200, Robert Wimmer wrote: 
> I've tried with NFSv3 now. With v4 the error normally occur
> within 5 minutes. The VM is now running for one hour and no
> soft lockup so far. So I would say it can't be reproduced with
> v3.

Thanks! That's useful info.

> >   - Have you tried running with stack tracing enabled?
> >   
> 
> Can you explain this a little bit more please? CONFIG_STACKTRACE=y
> was already enabled. I've now enabled
> 
> CONFIG_USER_STACKTRACE_SUPPORT=y
> CONFIG_NOP_TRACER=y
> CONFIG_HAVE_FTRACE_NMI_ENTER=y
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_FTRACE_SYSCALLS=y
> CONFIG_FTRACE_NMI_ENTER=y
> CONFIG_CONTEXT_SWITCH_TRACER=y
> CONFIG_GENERIC_TRACER=y
> CONFIG_FTRACE=y
> CONFIG_FUNCTION_TRACER=y
> CONFIG_FUNCTION_GRAPH_TRACER=y
> CONFIG_FTRACE_SYSCALLS=y
> CONFIG_STACK_TRACER=y
> CONFIG_KMEMTRACE=y
> CONFIG_DYNAMIC_FTRACE=y
> CONFIG_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_MMIOTRACE_SUPPORT=y
> 
> and run
> 
> echo 1 > /proc/sys/kernel/stack_tracer_enabled
> 
> But the output is mostly the same in dmesg/
> var/log/messages. Can you please guide me how I can
> enable the stack tracing you need?

Sure. In addition to what you did above, please do

mount -t debugfs none /sys/kernel/debug

and then cat the contents of the pseudofile at

/sys/kernel/debug/tracing/stack_trace

Please do this more or less immediately after you've finished mounting
the NFSv4 client.

Does your server have the 'crossmnt' or 'nohide' flags set, or does it
use the 'refer' export option anywhere? If so, then we might have to
test further, since those may trigger the NFSv4 submount feature.

Cheers
  Trond

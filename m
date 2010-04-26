From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
Date: Mon, 26 Apr 2010 08:15:54 -0400
Message-ID: <1272284154.4252.34.camel@localhost.localdomain>
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net>
	 <20100419131718.GB16918@redhat.com>
	 <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net>
	 <20100421094249.GC30855@redhat.com>
	 <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net>
	 <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net>
	 <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net>
	 <20100425204916.GA12686@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Robert Wimmer <kernel-PAwl83ecUlHR7s880joybQ@public.gmane.org>, Avi Kivity <avi@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429Ab0DZMP6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Apr 2010 08:15:58 -0400
In-Reply-To: <20100425204916.GA12686@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-04-25 at 23:49 +0300, Michael S. Tsirkin wrote: 
> So, it's an NFS-related regression, which is consistent with the bisect
> results. I guess someone who knows about NFS will have to look at it...
> BTW, you probably want to label the bug as regression.
> 
> On Sun, Apr 25, 2010 at 10:41:59PM +0200, Robert Wimmer wrote:
> > I've added CONFIG_KALLSYMS and CONFIG_KALLSYMS_ALL
> > to my .config. I've uploaded the dmesg output. Maybe it
> > helps a little bit:
> > 
> > https://bugzilla.kernel.org/attachment.cgi?id=26138
> > 
> > - Robert
> > 

That last trace is just saying that the NFSv4 reboot recovery code is
crashing (which is hardly surprising if the memory management is hosed).

The initial bisection makes little sense to me: it is basically blaming
a page allocation problem on a change to the NFSv4 mount code. The only
way I can see that possibly happen is if you are hitting a stack
overflow.
So 2 questions:

  - Are you able to reproduce the bug when using NFSv3 instead?
  - Have you tried running with stack tracing enabled?

Cheers
  Trond

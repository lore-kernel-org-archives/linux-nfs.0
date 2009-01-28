From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12564] New: poor performance while
 preprocessing source code
Date: Wed, 28 Jan 2009 13:29:42 -0800
Message-ID: <20090128132942.c957a199.akpm@linux-foundation.org>
References: <bug-12564-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steven-m+eqe7hsN2k@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52309 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752238AbZA1Vap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 16:30:45 -0500
In-Reply-To: <bug-12564-10286-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 28 Jan 2009 11:29:52 -0800 (PST)
bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12564
> 
>            Summary: poor performance while preprocessing source code
>            Product: IO/Storage

Thanks for the report.

>            Version: 2.5
>      KernelVersion: 2.6.28.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: io_other-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>         ReportedBy: steven-m+eqe7hsN2k@public.gmane.org
> 
> 
> Latest working kernel version: 2.6.26-rc3
> Earliest failing kernel version: 2.6.26-rc4 (or 2.6.26-rc3 + patch)

(huge performance regression in NFS)
 
> Distribution: gentoo
> 
> Hardware Environment:
>   Various 32 and 64 bit Intel and AMD machines with various
> PATA and SATA disks and various network interfaces.
> 
> Problem Description:
>   Here's my situation.  I've recently upgraded the kernels
> on ~30 computers at work (from 2.6.21 to 2.6.27).  These 
> computers are used to build and test software we develop.  
> We speed up the building process using distcc.  However,
> after the kernel upgrade, the builds are much much slower.
> The preprocessing stage seems to be at least 10 times
> slower.
>   As evidence of this slowdown I am attaching two images created
> using distccmon-gnome.  Both snapshots were taken shortly 
> after starting builds in a clean sandbox.  The only difference
> is the kernel.  "fast.png" was generated while running
> kernel 2.6.25.20.  "slow.png" was generated with 2.6.26.
> The light purple sections indicate the preprocessing times
> for each file.  
>   This slowdown is observed on both 32 and 64 bit computers
> and using either gcc or the intel compiler. (The intel compiler
> builds do not use distcc, but that are also slower.)  Strangely 
> enough, it's still faster to use an NFS mounted sandbox on a
> machine with an older kernel than the same sandbox on the local
> machine with a newer kernel.  (This suggests to me that it
> is neither a disk or network IO problem.)
>   I've used git bisect to narrow it down to a single commit:
> # bad: [b0b539739fe9b7d75002412a787cfdf4efddbc33] NFS: Ensure that 'noac'
> and/or 'actimeo=0' turn off attribute caching

And thanks for bisecting it.

> This is the first commit after v2.6.26-rc3.  I'm not an
> experienced git user, so I don't know how to narrow it down
> further.  Distccmon-gnome snapshots from the bisection
> process are similar to the ones noted above.
>   Naturally, I would like the newer kernels to have similar
> performance to the older kernels.
>   I will be attaching various items.  Let me know what other 
> information might be helpful.
> 
> Steps to reproduce:
> distccmon-gnome &
> # using a makefile setup to use distcc:
> make -j 5 all
> # note preprocessing times in distccmon
> 

Something I don't understand from this:

If your normal setup is using distcc then what role does NFS have to
play?  I mean, distcc kind-of replaces NFS in this workload.

Perhaps you could briefly describe the topology/data-flow/etc so that
we can see how NFS could be a bottleneck here?

Thanks.

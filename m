From: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: Strange NFS write performance Linux->Solaris-10/VXFS, maybe VW related
Date: Sat, 29 Dec 2007 01:59:00 -0800 (PST)
Message-ID: <701839.48516.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	spam trap <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32607.mail.mud.yahoo.com ([68.142.207.234]:39035 "HELO
	web32607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752265AbXL2J7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Dec 2007 04:59:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----
> From: Chris Snook <csnook@redhat.com>
> To: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-kernel@vger.kernel.org; linux-nfs@vger.kernel.org
> Sent: Friday, December 28, 2007 7:45:13 PM
> Subject: Re: Strange NFS write performance Linux->Solaris-10/VXFS, maybe VW related
> 
> Martin Knoblauch wrote:
> > Hi,
> > 
> > currently I am tracking down an "interesting" effect when writing
> to
> 
 a
> > Solars-10/Sparc based server. The server exports two filesystems.
> One
> 
 UFS,
> > one VXFS. The filesystems are mounted NFS3/TCP, no special
> options.
> 
 Linux
> > kernel in question is 2.6.24-rc6, but it happens with earlier kernels
> > (2.6.19.2, 2.6.22.6) as well. The client is x86_64 with 8 GB of ram.
> > 
> > The problem: when writing to the VXFS based filesystem,
> performance
> 
 drops
> > dramatically when the the filesize reaches or exceeds
> "dirty_ratio".
> 
 For a
> > dirty_ratio of 10% (about 800MB) files below 750 MB are
> transfered
> 
 with about
> > 30 MB/sec. Anything above 770 MB drops down to below 10 MB/sec. If
> I
> 
 perform
> > the same tests on the UFS based FS, performance stays at about
> 30
> 
 MB/sec
> > until 3GB and likely larger (I just stopped at 3 GB).
> > 
> > Any ideas what could cause this difference? Any suggestions
> on
> 
 debugging it?
> 
> 1) Try normal NFS tuning, such as rsize/wsize tuning.
>

  rsize/wsize only have minimal effect. The negotiated  size seems to be optimal.

> 2) You're entering synchronous writeback mode, so you can delay the
> 
 problem by raising dirty_ratio to 100, or reduce the size of the problem
> by lowering  dirty_ratio to 1.  Either one could help.
> 

 For experiments, sure. But I do not think that I want to have 8 GB of dirty pages [potentially] laying around. Are you sure that 1% is a useful value for dirty_ratio? Looking at the code, it seems a minimum of 5% is  enforced  in "page-writeback.c:get_dirty_limits":

        dirty_ratio = vm_dirty_ratio;
        if (dirty_ratio > unmapped_ratio / 2)
                dirty_ratio = unmapped_ratio / 2;

        if (dirty_ratio < 5)
                dirty_ratio = 5;


> 3) It sounds like the bottleneck is the vxfs filesystem.  It only
> 
 *appears* on  the client side because writes up until dirty_ratio get buffered on
> the client. 

 Sure, the fact that a UFS (or SAM-FS) based FS behaves well in the same situation points in that direction.

>   If you can confirm that the server is actually writing stuff to disk
> 
 slower  when the client is in writeback mode, then it's possible the Linux
> NFS client is  doing something inefficient in writeback mode.
> 

 I will try to get an iostat trace from the Sun side. Thanks for the suggestion.

Cheers
Martin
PS: Happy Year 2008 to all Kernel Hackers and their families




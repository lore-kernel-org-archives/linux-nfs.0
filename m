From: Chris Snook <csnook@redhat.com>
Subject: Re: Strange NFS write performance Linux->Solaris-10/VXFS, maybe VW
 related
Date: Fri, 28 Dec 2007 13:45:13 -0500
Message-ID: <47754439.4040200@redhat.com>
References: <713696.79839.qm@web32608.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbXL1SpQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Dec 2007 13:45:16 -0500
In-Reply-To: <713696.79839.qm-1+WuAixcP4WvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Martin Knoblauch wrote:
> Hi,
> 
> currently I am tracking down an "interesting" effect when writing to a
> Solars-10/Sparc based server. The server exports two filesystems. One UFS,
> one VXFS. The filesystems are mounted NFS3/TCP, no special options. Linux
> kernel in question is 2.6.24-rc6, but it happens with earlier kernels
> (2.6.19.2, 2.6.22.6) as well. The client is x86_64 with 8 GB of ram.
> 
> The problem: when writing to the VXFS based filesystem, performance drops
> dramatically when the the filesize reaches or exceeds "dirty_ratio". For a
> dirty_ratio of 10% (about 800MB) files below 750 MB are transfered with about
> 30 MB/sec. Anything above 770 MB drops down to below 10 MB/sec. If I perform
> the same tests on the UFS based FS, performance stays at about 30 MB/sec
> until 3GB and likely larger (I just stopped at 3 GB).
> 
> Any ideas what could cause this difference? Any suggestions on debugging it?

1) Try normal NFS tuning, such as rsize/wsize tuning.

2) You're entering synchronous writeback mode, so you can delay the problem by 
raising dirty_ratio to 100, or reduce the size of the problem by lowering 
dirty_ratio to 1.  Either one could help.

3) It sounds like the bottleneck is the vxfs filesystem.  It only *appears* on 
the client side because writes up until dirty_ratio get buffered on the client. 
  If you can confirm that the server is actually writing stuff to disk slower 
when the client is in writeback mode, then it's possible the Linux NFS client is 
doing something inefficient in writeback mode.

	-- Chris

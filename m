From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11448] New: NFS client has inconsistent write
 flushing to non-linux serversa
Date: Thu, 28 Aug 2008 13:27:53 -0700
Message-ID: <20080828132753.08bfe05f.akpm@linux-foundation.org>
References: <bug-11448-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, doug-rDJHdQPhaF8@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57172 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757323AbYH1U2Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2008 16:28:24 -0400
In-Reply-To: <bug-11448-10286-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 28 Aug 2008 11:41:08 -0700 (PDT)
bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11448
> 
>            Summary: NFS client has inconsistent write flushing to non-linux
>                     serversa
>            Product: File System
>            Version: 2.5
>      KernelVersion: 2.6.22.15
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: NFS
>         AssignedTo: trond.myklebust@fys.uio.no
>         ReportedBy: doug-rDJHdQPhaF8@public.gmane.org
> 
> 
> Latest working kernel version: N/A (works on 2.6.18 with Linux NFS server, but
> we cannot continue to use that kernel for various reasons)
> Earliest failing kernel version: N/A (2.6.18, 2.6.24, and 2.6.25 are also known
> to fail by another party experiencing same bug against non-Linux NFS servers).
> Not currently known to be reproducible against NetApp, but this is not
> authoritative (lack of seeing a bug does not guarantee lack of existence)
> Distribution: CentOS 4.6
> Hardware Environment: supermicro twin, 2 quad core Harpertown CPU, 16G ram.
> Software Environment: CentOS 4.6
> Problem Description: 
> 
> NFS client writes to Sun Solaris 10 U4 server. 
> at some point in time, there is an empty portion of the output file from the
> writer containing missing data (shows as NULL bytes from another NFS client
> issuing a tail -f on the file being written). 
> confirmed that the file as exists on the NFS server is sparse, missing bytes
> (not necessarily multiple of 512 or 1024, one sample is a gap of 3818 bytes,
> another is 1895 bytes, another is 423 bytes)
> 
> if you do a read of the entire file from the NFS client doing the writing, it
> causes the non-flushed writes to be instantly flushed to the server followed by
> a NFS3 commit operation. The data then can be seen on all other NFS clients.
> 
> If you do an open of the file alone, no flush
> if you do an open and a close, no flush
> if you do an open and a read at the beginning of the file (far before the data
> that is outstanding), *usually* no flush (one case where it did).
> If you do a read at another position in the file, no flush (other than as
> indicated above).
> If you do a read at the indicated offset where the bytes are null, it causes
> the NFS client to write and NFS commit to the server (truss output available)
> 
> The missing blocks may flush themselves after undefined periods of time which
> can be hours. Our runs last days.
> 
> Steps to reproduce:
> 
> Chemist running NAMD sees frequent cases of this in his output trajectory index
> files. We don't have an exact sequence of steps to reproduce. After I file this
> ticket I will be giving ticket number to another person I know at a different
> company experiencing the same problem as described above (to the best of my
> knowledge)
> 

That seems rather ugly.

2.6.22 is getting a bit old though.  It's quite possible that this was
subsequently fixed, in which case upgrading your kernel or hassling the
vendor to backport the fix would be needed.

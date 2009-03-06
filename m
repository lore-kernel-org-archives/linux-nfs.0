From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS significantly slow on uncache data, high %iowait, for
	kernel 2.6
Date: Fri, 6 Mar 2009 14:42:41 -0500
Message-ID: <20090306194241.GB32692@fieldses.org>
References: <49e80a6a0903050918y6043e729weba84715fadb0aaf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Igor Sola <iglesu@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:49205 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbZCFTmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2009 14:42:43 -0500
In-Reply-To: <49e80a6a0903050918y6043e729weba84715fadb0aaf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 05, 2009 at 10:18:55AM -0700, Igor Sola wrote:
> Apologies in advance if this email is inappropriate for this mailing
> list. If so please let me know of a more suitable one.
> 
> I noticed a significant performance difference when comparing a
> Centos5 (kernel 2.6.18) or Ubuntu (2.6.27-11) with a RH8 (kernel 2.4).
> All use NFS v3.
> The RH8 nfsd is faster than the 2.6 one even though it runs in an
> older, lower spec machine.
> 
> See test details below
> 
> Centos 5 x86_64 kernel 2.6.18-92.1.22.el5
> 
> RH8 2.4.20-30.8.multi_lun.smp #1 SMP  i386 GNU/Linux
> 
> 1Gb connection between machines
> 
> File sizes are 1GB. The read speed of these files in the local machine
> filesystem (server) is around 98MBs in the Centos5 machine and around
> 65MBs in the old RH8 machine.
> 
> .- First of all I wanted to measure how the network alone performs
> while using NFS.
> So in the server side I run a "cat" command on the 1GB file to
> /dev/null.  At this point the file system has the 1GB file cached in
> memory. In the client side a "cat" on the same file gives me a speed
> of about 113MBs. Which is consistent with the 1Gb network. There is no
> performance hit. So far so good.
> 
> 
> .- The second test is reading from disk an uncache (in server and
> client) file. In the server and client I made sure I flushed the 1GB
> file from the memory.  Between  Centos5 machines the performance was
> about 35MBs (64% drop from the 98MBs disk read). Between RH8 machines
> the performance was 55MBs (15% drop from the 65MBs)
> 
> This second test was repeated for ext2, ext3, xfs with no significant
> differences.
> 
> Please note that the %iowait more than doubles when reading the file
> from the NFS partition vs the file system partition in the 2.6 kernels
> 
> .- I run a third test just to make sure the problem is somehow related
> to the nfs daemon. I mounted the nfs partition local to the nfs server
> so the network was out the equation. I got the same poor results, no
> difference.
> 
> Any ideas are most welcome,

What version of nfs are you using, over what transport (tcp or udp)?
What are the export options?

I wonder if something's going wrong with readahead.

--b.

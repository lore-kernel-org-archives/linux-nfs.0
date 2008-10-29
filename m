From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS intr/nointr: SIGKILL may leave pages locked forever
Date: Wed, 29 Oct 2008 12:38:03 -0400
Message-ID: <E0B63DDE-B5D0-4DCA-B521-044759E1BFF0@oracle.com>
References: <1A5BADE4-02EB-473A-957A-2329DFBC92B3@oracle.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:59937 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbYJ2QiX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 12:38:23 -0400
In-Reply-To: <1A5BADE4-02EB-473A-957A-2329DFBC92B3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 24, 2008, at 11:11 AM, Chuck Lever wrote:
> Hi Matthew-
>
> We are still trying to pursue intr/nointr testing on 2.6.25+  
> kernels.  Looks like this week's kernel version is 2.6.27-rc7, but I  
> will need to confirm that.
>
> Since 2.6.25, the problem is the "sql shutdown abort" command, which  
> is designed to trigger an immediate database shutdown, causes the  
> database instance to hang.  It leaves database writer processes  
> stuck in "D" state after it sends a SIGKILL.
>
> The process backtraces suggest that these processes are waiting for  
> the inode mutex before trying to invalidate the database file's  
> cache (nfs_invalidate_mapping).  There is one process that owns the  
> mutex and is stuck waiting for a page lock in  
> invalidate_inode_pages2_range.  This suggests that the signal is  
> causing some other code path to neglect to unlock that page.
>
> It's a little out of my league.  Are there ways we can gather more  
> information?

As a follow-up, we've found that we don't have this problem on UP NFS  
clients.  On single processor clients, SIGKILL works correctly and the  
database shuts down without corrupting its data files.  On SMP  
clients, the signal results in hung database writers.

We've confirmed this difference on 2.6.25-rc2 and 2.6.27-rc7.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

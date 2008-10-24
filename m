From: Chuck Lever <chuck.lever@oracle.com>
Subject: NFS intr/nointr: SIGKILL may leave pages locked forever
Date: Fri, 24 Oct 2008 11:11:32 -0400
Message-ID: <1A5BADE4-02EB-473A-957A-2329DFBC92B3@oracle.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46074 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890AbYJXPLp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 11:11:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Matthew-

We are still trying to pursue intr/nointr testing on 2.6.25+ kernels.   
Looks like this week's kernel version is 2.6.27-rc7, but I will need  
to confirm that.

Since 2.6.25, the problem is the "sql shutdown abort" command, which  
is designed to trigger an immediate database shutdown, causes the  
database instance to hang.  It leaves database writer processes stuck  
in "D" state after it sends a SIGKILL.

The process backtraces suggest that these processes are waiting for  
the inode mutex before trying to invalidate the database file's cache  
(nfs_invalidate_mapping).  There is one process that owns the mutex  
and is stuck waiting for a page lock in  
invalidate_inode_pages2_range.  This suggests that the signal is  
causing some other code path to neglect to unlock that page.

It's a little out of my league.  Are there ways we can gather more  
information?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

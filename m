From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: [PATCH 0/3] Intro: Better handling coarse-grained timestamps
Date: Tue, 15 Jan 2008 11:27:01 -0500
Message-ID: <20080115162658.GA18911@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:57327 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbYAOQ1D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 11:27:03 -0500
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id m0FGSqCB019550
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2008 11:28:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While developing a new product that uses NFS here at EMC, we've run into
issues with cache coherency.  Our server uses ext3, and therefore can
only provide timestamps with a granularity of 1 second.  We have seen
cases where a directory is modified on the server, then a non-existent
filename within that directory is accessed from the client (returning
an error), and then the directory entry (either subdirectory or file)
gets added on the server, all within the same second.  This leads to
a cached negative dentry on the client, which results in erroneously
returning "file not found" to all future lstat()s and open()s, as the
timestamp on the parent directory has not been modified.

Ideally, all NFS servers would provide finer-grained timestamps, so 
that all changes to a directory also modify the timestamp.  However, it
is a reality that not every one will.  Therefore, we are attempting to
tackle this problem with the following three patches.

First, if the nlinks count changes, invalidate the cached data for the 
directory.  This is of limited use, as it only catches the cases where 
the number of subdirectories has changed.  However, because there is no 
really downside to checking the nlinks count, this check can be 
universally enabled.

Secondly, a modification to the kernel has been made to disable the 
caching of negative dentries when the NFS_MOUNT_NONEGDE flag is set.  
Note that this does nothing to address outdated information being 
returned by readdir().  However, it does allow a file to be open()ed or 
lstat()ed if the filename is known.  Because this has a potential 
performance impact, it is left as an option for the user to select.

Lastly, changes have been made to userspace to accept the "nonegde" 
mount option and set the NFS_MOUNT_NONEGDE flag.

Your review and comments are greatly appreciated.  I believe this is 
a fairly basic patch, and it has worked well in testing so far on SLES
10 (with slight modifications to match the software versions in SLES
10).  Most of this patch is fairly trivial; my only open question is
whether "nonegde" is a good name (I myself sometimes read it as
"non-edge", but have yet to come up with anything better).

-- 
Bob Bell

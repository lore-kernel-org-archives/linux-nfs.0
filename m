From: "Vivek Goyal" <vivek.goyal@wipro.com>
Subject: Disabling Symbolic Link Content Caching in NFS Client
Date: Wed, 28 May 2003 16:39:36 +0530
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <2BB7146B38D9CA40B215AB3DAAE24C080BA4F3@blr-m2-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <trond.myklebust@fys.uio.no>, <indou.takao@jp.fujitsu.com>,
	"Vivek Goyal" <vivek.goyal@wipro.com>, <ionut@cs.columbia.edu>,
	<ezk@cs.sunysb.edu>, <viro@math.psu.edu>, <davem@redhat.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
List-ID: <nfs.lists.sourceforge.net>

Hi,

We are planning to implement a set of Kernel Tunable Parameters and one
of these parameters is nfs_symlink_caching for disabling/enabling
symbolic link content caching in NFS client. Unices like Solaris have
this feature implemented.

Existing NFS client implementation in Linux performs symbolic link
content caching by default. There is no provision for disabling this
caching either at mount time or through kernel tuning mechanism.

This caching mechanism leads to problems in following two conditions.

a. File is modified in server without updating the modification
time-stamp.
b. Granularity of the time-stamp is too large.

I was following previous discussions in the mailing list and found that
caching mechanism affected hlfsd behavior. It looks like the problem was
resolved by updating mtime on every access. But still caching will lead
to a problem if two accesses are taking place in same jiffy.

We are considering following design strategy to implement the parameter.

1. Make nfs_symlink_caching dynamically tunable using /proc and sysctl
interface.

2. Change NFS client code as follows.

A. If caching is enabled.
There are no changes. Existing caching mechanism remains intact.

B. If caching is disabled.

	i. While serving a symlink read request (nfs_getlink ()) don't
look for the requested page in page cache (read_cache_page()). Instead
always allocate a page frame (page_cache_alloc_cold()) and send a
READLINK request to the server. This allocated page frame is not added
to the cache and hence remains local to the thread of execution and is
not visible to other execution threads.

	ii. Upon receiving the response from the server, pass the data
to the user space and free the page frame. 

Please let us know your comments/opinion on this design.

Thanks and Regards
Vivek

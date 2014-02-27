Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:40771 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbaB0U4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Feb 2014 15:56:16 -0500
Date: Thu, 27 Feb 2014 21:50:29 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, xfs@oss.sgi.com
Subject: Re: xfstests with NFS
Message-ID: <20140227205029.GA29741@lst.de>
References: <27AB99CF-CEF3-4AC5-AFBD-6648F3B3BED2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <27AB99CF-CEF3-4AC5-AFBD-6648F3B3BED2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 27, 2014 at 10:32:51AM -0800, Chuck Lever wrote:
> 
> I’m running xfstests to validate functionality of a particular
> NFS client/transport/server set up.
> 
> There are a couple of tests that may not always be appropriate for
> FSTYP=nfs.  We weren’t able to identify a bugzilla where we can report
> these issues.

Just send the to the xfs list.  (and cap lines after 75 chars like for all
Linux lists..)

> generic/192 tests atime changes.  The Linux NFS client (and probably
> others) typically optimizes away atime changes.  Thus this test fails
> for NFS mounts on Linux.  I’m wondering if we can treat NFS as always
> a noatime filesystem.

I guess there's two components to this if we want to do it properly:

 - make sure nfs always reports noatime in /proc/self/mounts instead
   of incorrectly claiming it supports relatime by default
 - _notrun 192 if it detects the filesystems reports noatime.

> generic/237 tries setfacl.  On NFS mounts, the operation always returns
> “Operation not supported,” but the test is looking for “Operation not
> permitted.”  The former is an acceptable pass, IMO.  I considered
> disabling this test for NFS, but I would bet some NFS client
> implementations actually do support setfacl().

The NFSv3 client support ACLs perfectly, it's just NFSv4 that's messed up.

237 does a _require_acls before ding thæ test, which checks for
ENOSYS or EOPNOTSUPP, which in theory should catch NFSv4 in theory, but
if this doesn't happen try to debug it by looking at the _require_acls shell
function, the chacl implementation, the NFSv4 ACL stubs and anything else
related.


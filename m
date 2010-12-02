Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63940 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab0LBSLQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 13:11:16 -0500
Subject: Re: nfsroot mount options
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101202170915.GB15530@merit.edu>
Date: Thu, 2 Dec 2010 13:11:09 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <5B25CFFD-16E3-4BAB-A344-4337F0C79862@oracle.com>
References: <20101202001821.GA12638@merit.edu> <11945697-DC88-4EB3-A9C8-F2A27E0E79BD@oracle.com> <20101202170915.GB15530@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 2, 2010, at 12:09 PM, Jim Rees wrote:

> Chuck Lever wrote:
> 
>  On Dec 1, 2010, at 7:18 PM, Jim Rees wrote:
> 
>> If I boot diskless with nfsroot, why is the root file system mounted
>> readonly?  This makes sense for a file system on disk, since it may have to
>> be checked before remounting rw, but I don't see why this is needed for
>> nfsroot.
>> 
>> Also, Documentation/filesystems/nfs/nfsroot.txt says that only nfs options
>> can be given on the kernel nfsroot option, but I've seen a claim that you
>> can also put "rw" here.  Are other generic options possible?  How about the
>> nfs options that aren't listed in the doc?  Should the doc be updated?
> 
>  What kernel version are you looking at?  I think 2.6.37-rc has some
>  nfsroot updates that allow all NFS options to be used.
> 
>  Not sure about the generic mount options.  Why not just try them and see?
> 
> This is Ubuntu lucid, so 2.6.32.  I'm less concerned about the documentation
> defect than the question about the default being readonly.  Is there any
> good reason other than to match the behavior of non-nfs root?
> 
> I ask because there has been a bug in ubuntu for a long time (a couple of
> releases) that prevents nfsroot from working.  Their mountall is broken and
> can't remount an nfs root rw.  They need to fix this obviously, but it got
> me to wondering why the remount should be needed at all.
> 
> The bug report is here:
> https://bugs.launchpad.net/ubuntu/+source/mountall/+bug/537133

OK, Ubuntu doesn't use NFSROOT (the kernel's implementation), it actually does a real mount in user space.  So all the normal NFS and generic mount options ought to work.

However, I worked on the kernel's implementation recently, not Ubuntu's "nfsroot", so that's as far as my expertise goes.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





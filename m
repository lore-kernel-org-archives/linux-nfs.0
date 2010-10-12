From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: whither NFS umount?
Date: Tue, 12 Oct 2010 13:57:53 -0400
Message-ID: <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com> <1286903046.24878.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63220 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757389Ab0JLR6X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 13:58:23 -0400
In-Reply-To: <1286903046.24878.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 12, 2010, at 1:04 PM, Trond Myklebust wrote:

> On Tue, 2010-10-12 at 12:29 -0400, Chuck Lever wrote:
>> I've been looking at a bug where "mount.nfs -o remount" wipes all the mount options for that mount out of /etc/mtab, thereby making umounting break.
>> 
>> This is a tough nut to crack in user space... Not even utils-linux-ng seems to get mtab option rewriting correct in this case.
>> 
>> Jeff suggested a few weeks ago that we should just chuck user space umount and go with a kernel umount implementation.  I'm beginning to think that is a good strategy, even though a UMNT request is advisory.
>> 
>>  + Only the kernel knows when the last instance of a shared mount point is gone -- only then should a UMNT be sent to the server
>> 
>>  + The kernel might do a delayed lazy UMNT.  It would avoid sending a UMNT until the client is actually done using the export.  Today we just don't send UMNT at all in this case
>> 
>>  + The kernel preserves the original mount options in an internal data structure rather than in /etc/mtab, even after a remount.  This eliminates the NFS requirement for /etc/mtab -- one step closer to getting rid of it
>> 
>>  + The kernel already handles umounts for under-the-cover NFSv4 mounts, right?
>> 
>>  + The kernel is the authority on what is an NFSv4 mount point, so it knows exactly what kind of umount to do every time (send a UMNT or not)
>> 
>>  + There is already a UMNT client in the kernel, used when the kernel's MNT request fails such that a UMNT is needed
>> 
>> Thoughts, comments?
>> 
> 
> UMNT is an advisory thing. If it causes problems, then lets just drop
> it.

Out of interest, what would that look like?  Would we rip out all code from nfsumount.c and network.c that handles UMNT calls?

-- 
chuck[dot]lever[at]oracle[dot]com





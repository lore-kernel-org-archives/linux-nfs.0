From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Tue, 15 Jan 2008 12:04:50 -0500
Message-ID: <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
References: <20080115163013.GC18911@newbie.thebellsplace.net> <1200415972.7702.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:64558 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYAORFE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:05:04 -0500
In-Reply-To: <1200415972.7702.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2008, at 11:52 AM, Trond Myklebust wrote:
> On Tue, 2008-01-15 at 11:30 -0500, Bob Bell wrote:
>> From: Bob Bell <bell_robert@emc.com>
>>
>> Add NFS_MOUNT_NONEGDE mount flag.  When this flag is set on a mounted
>> NFS filesystem, negative dentries for that filesystem will not be
>> cached.  This can help address cache coherency when the NFS server  
>> does
>> not provide sufficiently fine-grained timestamps to consistently
>> distinguish when a directory has been modified, though performance  
>> when
>> repeatedly accessing filenames for files that do not exist may be
>> impacted.
>>
>> Signed-off-by: Bob Bell <bell_robert@emc.com>
>> ---
>
> The patch itself looks OK. My only gripe is the two names 'negde' and
> 'nonegde'. Can we find something that rolls a bit more smoothly off  
> the
> tongue?

Yeah, actually I thought it was spelled "non edge" until I looked  
closer.

> How about something like 'cacheneglookup' 'nocacheneglookup'? Better
> suggestions, anyone?


I suspect system administrators have no idea what a "negative dentry"  
is, and it would probably be beyond the scope of nfs(5) to explain  
it.  So I vote for something that describes the behavior as observed  
by a "lay person" rather than something that names the kernel  
mechanisms involved.

You might consider tying this behavior to "noac" as well.  In other  
words, make "noac" equivalent to "sync,actimeo=0,nonegde" .

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




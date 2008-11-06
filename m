From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 6 Nov 2008 14:15:41 -0500
Message-ID: <3686E17F-DBFB-466C-94C9-4B820893C16B@oracle.com>
References: <200811061034.06486.asid@hp.com> <1225997396.387.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Alex Sidorenko <asid@hp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:17762 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbYKFTPz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 14:15:55 -0500
In-Reply-To: <1225997396.387.30.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 6, 2008, at Nov 6, 2008, 1:49 PM, Trond Myklebust wrote:
> On Thu, 2008-11-06 at 10:34 -0500, Alex Sidorenko wrote:
>> I understand the reasoning behind that. From application point of  
>> view, NFS
>> file/directory should behave the same as on local FS. If we have  
>> queued many
>> writes, without this patch stat() will return incorrect results,  
>> both for
>> mtime and file length. Some applications may depend on stat()  
>> results being
>> correct.
>>
>> At the same time, the fact that we have to wait forever while  
>> copying big
>> files and doing 'ls -l' on that directory (or on the file being  
>> written) is
>> not very good either (two HP customers have complained about this  
>> after
>> migrating from RHEL4 to RHEL5).
>
> In order to relax that requirement, we'd have to introduce some
> mechanism for the application to notify the filesystem that they don't
> care about strictly correct c/mtimes. As you noted above, returning
> incorrect mtimes may trip up some applications (backup applications,  
> and
> mail readers are a couple of business critical cases that come to  
> mind).

I thought the preferred way to address this issue was to limit the per- 
file write cache size on the client.  That is effectively what you do  
with "-osync" as you suggest below.

Especially on big systems, the client will delay writes until the cows  
come home.  Then someone does a stat(2) and the lights dim... Really  
the client shouldn't need to cache that aggressively, and there are  
good reasons to keep a cap on it.

>> The problem is still there in 2.6.27. I am not sure what can be  
>> done to both
>> reduce the stat() delay and guarantee reasonable stat() results.
>>
>> It is interesting that with 'noac' stat() returns much faster (just  
>> 1-3s
>> delay).
>
> That would be because 'noac' enforces synchronous writes. If you don't
> care about the degraded write performance, you can do the same thing
> without all the extra getattr clutter that noac introduces, by simply
> mounting with -osync.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

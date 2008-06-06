From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: size of nfsv4 writes
Date: Thu, 05 Jun 2008 17:25:18 -0700
Message-ID: <484883EE.2060802@gmail.com>
References: <4846C586.1050000@citi.umich.edu> <1212597977.7422.4.camel@localhost> <48471180.8090208@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:57059 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYFFAZW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2008 20:25:22 -0400
Received: by wf-out-1314.google.com with SMTP id 27so714582wfd.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2008 17:25:21 -0700 (PDT)
In-Reply-To: <48471180.8090208@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Olga Kornievskaia wrote:
>
>
> Trond Myklebust wrote:
>> On Wed, 2008-06-04 at 12:40 -0400, Olga Kornievskaia wrote:
>>  
>>> While testing NFSv4 performance over the 10GE network, we are seeing 
>>> the following behavior and would like to know if it is normal or a 
>>> bug in the client code.
>>>
>>> The server offers the max_write of 1M. The client mounts the server 
>>> with the "wsize" option of 1M. Yet during the write we are seeing 
>>> that the write size is at most 49K. Why does client never come close 
>>> to 1M limit?
Does /proc/mounts indicate 1M?  As a total guess, could there be 
something going on in nfs_can_coalesce_requests 
</lxr-pnfs/ident?i=nfs_can_coalesce_requests>?  (I can't imagine why, 
but we had a pnfs problem where our additions to 
nfs_can_coalesce_requests were causing similar behavior)
>>>     
>>
>> I have a feeling that is due to some crap in the VM. I'm currently
>> investigating a situation where it appears we're sending 1 COMMIT for
>> every 1-5 32k WRITEs. This is not a policy that stems from the NFS
>> client, so it would appear that the VM is being silly about things.
>>
>> I'm specially suspicious of the code in get_dirty_limits() that is
>> setting a limit to the number of dirty pages based on the number of
>> pages a given BDI has written out in the recent past. As far as I can
>> see, the intention is to penalise devices that are slow writers, but in
>> practice it doesn't do that: it penalises the devices that have the
>> least activity.
>>
>>   
> I think we are seeing larger than usual number of COMMIT messages.
With older kernels, no matter how I configured linux to flush dirty 
pages, it would always flush too often and hence send way too many 
commit messages.  But more like every couple hundred megabytes..... 

If you don't need the page cache, I have found that O_DIRECT can 
increase performance by giving predefined points at which the client 
will commit.
Dean
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

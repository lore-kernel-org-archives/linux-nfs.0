From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Fri, 29 May 2009 13:47:12 -0400
Message-ID: <62B205CB-2C9E-4F76-ACA4-D5F9076A7EDB@oracle.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com> <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com> <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org> <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com> <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com> <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com> <1243618968.7155.60.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:37841 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbZE2Rrj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 13:47:39 -0400
In-Reply-To: <1243618968.7155.60.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 29, 2009, at 1:42 PM, Trond Myklebust wrote:

> On Fri, 2009-05-29 at 13:38 -0400, Brian R Cowan wrote:
>>> You may have a misunderstanding about what exactly "async" does.   
>>> The
>>> "sync" / "async" mount options control only whether the application
>>> waits for the data to be flushed to permanent storage.  They have no
>>> effect on any file system I know of _how_ specifically the data is
>>> moved from the page cache to permanent storage.
>>
>> The problem is that the client change seems to cause the  
>> application to
>> stop until this stable write completes... What is interesting is  
>> that it's
>> not always a write operation that the linker gets stuck on. Our best
>> hypothesis -- from correlating times in strace and tcpdump traces  
>> -- is
>> that the FILE_SYNC'ed write NFS RPCs are in fact triggered by  
>> *read()*
>> system calls on the output file (that is opened for read/write). We  
>> THINK
>> the read call triggers a FILE_SYNC write if the page is dirty...and  
>> that
>> is why the read calls are taking so long. Seeing writes happening  
>> when the
>> app is waiting for a read is odd to say the least... (In my test,  
>> there is
>> nothing else running on the Virtual machines, so the only thing  
>> that could
>> be triggering the filesystem activity is the build test...)
>
> Yes. If the page is dirty, but not up to date, then it needs to be
> cleaned before you can overwrite the contents with the results of a
> fresh read.
> That means flushing the data to disk... Which again means doing  
> either a
> stable write or an unstable write+commit. The former is more efficient
> that the latter, 'cos it accomplishes the exact same work in a single
> RPC call.

It might be prudent to flush the whole file when such a dirty page is  
discovered to get the benefit of write coalescing.

> Trond
>
>> =================================================================
>> Brian Cowan
>> Advisory Software Engineer
>> ClearCase Customer Advocacy Group (CAG)
>> Rational Software
>> IBM Software Group
>> 81 Hartwell Ave
>> Lexington, MA
>>
>> Phone: 1.781.372.3580
>> Web: http://www.ibm.com/software/rational/support/
>>
>>
>> Please be sure to update your PMR using ESR at
>> http://www-306.ibm.com/software/support/probsub.html or cc all
>> correspondence to sw_support@us.ibm.com to be sure your PMR is  
>> updated in
>> case I am not available.
>>
>>
>>
>> From:
>> Chuck Lever <chuck.lever@oracle.com>
>> To:
>> Brian R Cowan/Cupertino/IBM@IBMUS
>> Cc:
>> Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org 
>> ,
>> linux-nfs-owner@vger.kernel.org, Peter Staubach <staubach@redhat.com>
>> Date:
>> 05/29/2009 01:02 PM
>> Subject:
>> Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page  
>> flushing
>> Sent by:
>> linux-nfs-owner@vger.kernel.org
>>
>>
>>
>>
>> On May 29, 2009, at 11:55 AM, Brian R Cowan wrote:
>>
>>> Been working this issue with Red hat, and didn't need to go to the
>>> list...
>>> Well, now I do... You mention that "The main type of workload we're
>>> targetting with this patch is the app that opens a file, writes < 4k
>>> and
>>> then closes the file." Well, it appears that this issue also impacts
>>> flushing pages from filesystem caches.
>>>
>>> The reason this came up in my environment is that our product's  
>>> build
>>> auditing gives the the filesystem cache an interesting workout. When
>>> ClearCase audits a build, the build places data in a few places,
>>> including:
>>> 1) a build audit file that usually resides in /tmp. This build audit
>>> is
>>> essentially a log of EVERY file open/read/write/delete/rename/etc.
>>> that
>>> the programs called in the build script make in the clearcase "view"
>>> you're building in. As a result, this file can get pretty large.
>>> 2) The build outputs themselves, which in this case are being
>>> written to a
>>> remote storage location on a Linux or Solaris server, and
>>> 3) a file called .cmake.state, which is a local cache that is
>>> written to
>>> after the build script completes containing what is essentially a
>>> "Bill of
>>> materials" for the files created during builds in this "view."
>>>
>>> We believe that the build audit file access is causing build output
>>> to get
>>> flushed out of the filesystem cache. These flushes happen *in 4k
>>> chunks.*
>>> This trips over this change since the cache pages appear to get
>>> flushed on
>>> an individual basis.
>>
>> So, are you saying that the application is flushing after every 4KB
>> write(2), or that the application has written a bunch of pages, and  
>> VM/
>> VFS on the client is doing the synchronous page flushes?  If it's the
>> application doing this, then you really do not want to mitigate this
>> by defeating the STABLE writes -- the application must have some
>> requirement that the data is permanent.
>>
>> Unless I have misunderstood something, the previous faster behavior
>> was due to cheating, and put your data at risk.  I can't see how
>> replacing an UNSTABLE + COMMIT with a single FILE_SYNC write would
>> cause such a significant performance impact.
>>
>>> One note is that if the build outputs were going to a clearcase view
>>> stored on an enterprise-level NAS device, there isn't as much of an
>>> issue
>>> because many of these return from the stable write request as soon
>>> as the
>>> data goes into the battery-backed memory disk cache on the NAS.
>>> However,
>>> it really impacts writes to general-purpose OS's that follow Sun's
>>> lead in
>>> how they handle "stable" writes. The truly annoying part about this
>>> rather
>>> subtle change is that the NFS client is specifically ignoring the
>>> client
>>> mount options since we cannot force the "async" mount option to turn
>>> off
>>> this behavior.
>>
>> You may have a misunderstanding about what exactly "async" does.  The
>> "sync" / "async" mount options control only whether the application
>> waits for the data to be flushed to permanent storage.  They have no
>> effect on any file system I know of _how_ specifically the data is
>> moved from the page cache to permanent storage.
>>
>>> =================================================================
>>> Brian Cowan
>>> Advisory Software Engineer
>>> ClearCase Customer Advocacy Group (CAG)
>>> Rational Software
>>> IBM Software Group
>>> 81 Hartwell Ave
>>> Lexington, MA
>>>
>>> Phone: 1.781.372.3580
>>> Web: http://www.ibm.com/software/rational/support/
>>>
>>>
>>> Please be sure to update your PMR using ESR at
>>> http://www-306.ibm.com/software/support/probsub.html or cc all
>>> correspondence to sw_support@us.ibm.com to be sure your PMR is
>>> updated in
>>> case I am not available.
>>>
>>>
>>>
>>> From:
>>> Trond Myklebust <trond.myklebust@fys.uio.no>
>>> To:
>>> Peter Staubach <staubach@redhat.com>
>>> Cc:
>>> Chuck Lever <chuck.lever@oracle.com>, Brian R Cowan/Cupertino/
>>> IBM@IBMUS,
>>> linux-nfs@vger.kernel.org
>>> Date:
>>> 04/30/2009 05:23 PM
>>> Subject:
>>> Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
>>> flushing
>>> Sent by:
>>> linux-nfs-owner@vger.kernel.org
>>>
>>>
>>>
>>> On Thu, 2009-04-30 at 16:41 -0400, Peter Staubach wrote:
>>>> Chuck Lever wrote:
>>>>>
>>>>> On Apr 30, 2009, at 4:12 PM, Brian R Cowan wrote:
>>>>>>
>>>>>>
>>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ab0a3dbedc51037f3d2e22ef67717a987b3d15e2
>>
>>>
>>>>>>
>>>> Actually, the "stable" part can be a killer.  It depends upon
>>>> why and when nfs_flush_inode() is invoked.
>>>>
>>>> I did quite a bit of work on this aspect of RHEL-5 and discovered
>>>> that this particular code was leading to some serious slowdowns.
>>>> The server would end up doing a very slow FILE_SYNC write when
>>>> all that was really required was an UNSTABLE write at the time.
>>>>
>>>> Did anyone actually measure this optimization and if so, what
>>>> were the numbers?
>>>
>>> As usual, the optimisation is workload dependent. The main type of
>>> workload we're targetting with this patch is the app that opens a
>>> file,
>>> writes < 4k and then closes the file. For that case, it's a no- 
>>> brainer
>>> that you don't need to split a single stable write into an unstable
>>> + a
>>> commit.
>>>
>>> So if the application isn't doing the above type of short write
>>> followed
>>> by close, then exactly what is causing a flush to disk in the first
>>> place? Ordinarily, the client will try to cache writes until the  
>>> cows
>>> come home (or until the VM tells it to reclaim memory - whichever
>>> comes
>>> first)...
>>>
>>> Cheers
>>> Trond
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




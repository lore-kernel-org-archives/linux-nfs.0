From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Wed, 30 Jan 2008 16:01:45 -0500
Message-ID: <AB6DF303-5C5B-453C-9992-DAF826FF02CE@oracle.com>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com> <4791EE99.3030802@abinetworks.biz> <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com> <479C744A.6020207@abinetworks.biz> <12964A18-350B-443F-B15A-D78B3723C89A@oracle.com> <479F2463.2040704@abinetworks.biz> <4AAA3DAF-898C-4ED5-BD07-4FD2B5CEEF16@oracle.com> <Pine.LNX.4.64.0801291851110.4820@maggie.lkpg.cendio.se> <7EE4B02B-3359-41C0-BFED-0947DF9F5F5A@oracle.com> <479F8377.6090704@abinetworks.biz> <1201638661.7969.7.camel@heimdal.trondhjem.org> <F7BFE847-A3C3-44E5-A238-5C69ED3EE1C4@oracle.com> <47A0704D.7080808@abinetworks.biz>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	=?ISO-8859-1?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:33473 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbYA3VDN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2008 16:03:13 -0500
In-Reply-To: <47A0704D.7080808-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Gianluca-

On Jan 30, 2008, at 7:40 AM, Gianluca Alberici wrote:
> Hello again everybody
>
> Here follows the testbench:
>
> - I got two mirrors, same machine, same disk etc...chaged hostname,  
> IP, and on the second i have recompiled kernel.
> - First: 2.6.21.7 on debian sarge
> - Second: 2.6.22 same system.
> - Onto both i got nfs-user-server and cfsd last versions
> - The export file is the same (localhost /opt/nfs (rw, async),  
> stripping off the async option does not changes anything)
> - Mount options are exactly the same.
>
> The problem arises in the very same manner with both nfs and cfsd:
>
> NFS:setattr {
> ...
> ...
> RPC:call_decode {
> return 22;
> }
> ...
> return 22;
> }

Again, there is nothing wrong with the RPC client or call_decode.   
The *server* is returning NFSERR_INVAL (22) to a SETATTR request; the  
RPC client is simply passing that along to the NFS client, as it is  
designed to do.

> I have tried these kernels:
>
> 2.6.16.11	works
> 2.6.20		works
> 2.6.21		works
> 2.6.21.7	works
> 2.6.22		doesnt work (contiguous to previous version)
> 2.6.23		doesnt work (same behavior as previous)
> 2.6.23.9	doesnt work (as above)
> 2.6.24rc7	doesnt work (as above)
>
> I would really like to do more, client or server side, if you ave  
> any suggestions.
> Can we find out what is the change (doesnt matter if it is a buf or  
> bug fix) that caused this problem ?

The goal here is to identify the kernel change between 2.6.21 and  
2.6.22 that makes the client generate SETATTR requests the user-space  
server chokes on.  It may be a change in the NFS client, or it could  
be somewhere else in the file system stack, like the VFS.

The usual procedure is to use "git bisect".  It does a binary search  
on the kernel patches between the working kernel version and the  
kernel version that is known not to work.  It works like this:

1.  You clone a linux kernel git repository (if you don't have a git
     repository already)

2.  You tell git bisect which kernel version is working, and which  
isn't.
     git bisect then selects a commit about half way in between the  
working
     and non-working versions, and checks out that version of the kernel

3.  You build that kernel, and run your test case

4.  You tell git bisect whether the resulting kernel passes your test  
case,
     it selects a new commit, and checks out that version of the kernel.

5.  Repeat steps 3 and 4 until git bisect has identified the commit that
     causes the kernel to stop passing your test case

If the number of patches between 2.6.21 and 2.6.22 is N, then git  
bisect will find the faulty patch in O(log2(N)) steps.  For example,  
if there are 250 patches between 2.6.21 and 2.6.22, it will take  
about 8 iterations of steps 3 and 4 to find the faulty patch, if all  
goes well; far fewer than the total number of patches you would need  
to test one at a time.

Naturally you can also do this by applying and reverting patches with  
"patch -p1", but it's a little more work.

> Chuck Lever wrote:
>
>> On Jan 29, 2008, at 3:31 PM, Trond Myklebust wrote:
>>
>>> On Tue, 2008-01-29 at 20:50 +0100, Gianluca Alberici wrote:
>>>
>>>> Hello,
>>>>
>>>> I confirm that i have encountered this same problem (EINVAL on open
>>>> (...O | TRUNC) with the following userspace servers:
>>>>
>>>> - nfs-user-server shipped with debian sarge/etch etc...
>>>> - cfsd (crypto file system which is an nfs server)
>>>>
>>>> I want to underline again that these userspace servers have been  
>>>> woking
>>>> perfectly until 2.6.21.7 (which is the last 2.6.21)
>>>> Since 2.6.22 the problem came out and it is still present into  
>>>> 2.6.24
>>>> rc7 (last i tested). Conclusion: there must have been something  
>>>> that is
>>>> changed in 2.6.22 that caused the problem.
>>>
>>>
>>> The only difference between these two dumps are the fact that the  
>>> first
>>> one isn't using the Sun convention for telling NFSv2 servers to  
>>> set to
>>> the current time (see the code in xdr_encode_current_server_time).
>>
>>
>> I thought I saw that on both SETATTRs, but I could be wrong.
>>
>>> I don't see why this would be new behaviour after 2.6.21. The  
>>> code for
>>> this has been in the NFS client since 2.6.15 at least...
>>
>>
>>
>> A mount option is set on one test client, and not the other, perhaps?
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




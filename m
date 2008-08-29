From: Doug Hughes <doug-rDJHdQPhaF8@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11448] New: NFS client has inconsistent write
 flushing to non-linux serversa
Date: Fri, 29 Aug 2008 14:27:42 -0400
Message-ID: <48B83F9E.6080703@will.to>
References: <bug-11448-10286@http.bugzilla.kernel.org/> <20080828132753.08bfe05f.akpm@linux-foundation.org> <20080829170838.GA7099@fieldses.org> <48B82E61.6060609@redhat.com> <48B83091.7060800@will.to> <48B83792.5060004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman.will.to ([68.164.136.125]:36927 "EHLO will.to"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554AbYH2S2K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 14:28:10 -0400
In-Reply-To: <48B83792.5060004@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Staubach wrote:
> Doug Hughes wrote:
>> Peter Staubach wrote:
>>> J. Bruce Fields wrote:
>>>> On Thu, Aug 28, 2008 at 01:27:53PM -0700, Andrew Morton wrote:
>>>>  
>>>>> (switched to email.  Please respond via emailed reply-to-all, not 
>>>>> via the
>>>>> bugzilla web interface).
>>>>>
>>>>> On Thu, 28 Aug 2008 11:41:08 -0700 (PDT)
>>>>> bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>>>>>  
>>>>>> NFS client writes to Sun Solaris 10 U4 server. at some point in 
>>>>>> time, there is an empty portion of the output file from the
>>>>>> writer containing missing data (shows as NULL bytes from another 
>>>>>> NFS client
>>>>>> issuing a tail -f on the file being written). confirmed that the 
>>>>>> file as exists on the NFS server is sparse, missing bytes
>>>>>> (not necessarily multiple of 512 or 1024, one sample is a gap of 
>>>>>> 3818 bytes,
>>>>>> another is 1895 bytes, another is 423 bytes)
>>>>>>       
>>>>
>>>> Seems like something that could happen if for example two write rpc's
>>>> got reordered on the network.  That's not necessarily a bug--the nfs
>>>> client isn't required to wait for confirmation of every previous write
>>>> before sending the next one.
>>>>
>> if two RPCs got reordered on the network, and they encompass all the 
>> data, then there shouldn't be any missing data. It seems to me like 
>> pieces of data are just being skipped, for whatever reason, but I 
>> haven't exhaustively examined the NFS network data.
>>
>>>> However if the client isn't flushing dirty data to the server before
>>>> returning from close, then that's a violation of NFS's close-to-open
>>>> semantics:...
>>>>
>> this is not confirmed yet. No solid cases of data not being present 
>> after close.
>>>>  
>>>>>> if you do a read of the entire file from the NFS client doing the 
>>>>>> writing, it
>>>>>> causes the non-flushed writes to be instantly flushed to the 
>>>>>> server followed by
>>>>>> a NFS3 commit operation. The data then can be seen on all other 
>>>>>> NFS clients.
>>>>>>
>>>>>> If you do an open of the file alone, no flush
>>>>>> if you do an open and a close, no flush
>>>>>>       
>>>>
>>>> ... so this "close, no flush" could be a bug (depending on who is 
>>>> doing
>>>> that close when--I don't completely understand the described 
>>>> situation).
>>>
>>> I suspect that this last might depend upon 1) what options were used
>>> when the file system was mounted and 2) how the file was opened.  The
>>> flush-on-close wouldn't be needed if the file was opened read-only.
>>>
>> no special options on open. Here are the mount options:
>> retry=1000,tcp,noatime,nosuid,nodev,dirsync,timeo=100,rsize=32768,wsize=32768 
>>
>> ,hard,intr
>>
>>
>>> It seems a little odd that the holes aren't page aligned or page
>>> sized multiples.
>>>
>> indeed. and the time for them to actually get to the server is 
>> indeterminate (days is not uncommon. We have not as yet confirmed 
>> that some of the data never gets sent to the server until close)
>>
>>> What application is being used to generate the file which is showing
>>> these holes?
>>>
>> namd and some custom code developed in-house for chemistry research 
>> (at the very least) 
>
> Do these applications use mmap() or generate the file contents
> serially or randomly?
>
>    Thanx...
>
>  
open file at beginning. write, write, write, write, write, (no seek, no 
offset, entirely serial), run a very long time, end.

strace excerpt:
16:42:56.143512 write(8, "1948900 47.1225 0 0 0 47.7759 0 "..., 118) = 118
16:43:01.845742 write(8, "1949000 47.0474 0 0 0 47.8865 0 "..., 116) = 116
16:43:07.481889 write(8, "1949100 47.045 0 0 0 48.0742 0 0"..., 116) = 116
16:43:13.150555 write(8, "1949200 47.1848 0 0 0 47.8868 0 "..., 116) = 116
16:43:18.788863 write(8, "1949300 47.251 0 0 0 47.7743 0 0"..., 113) = 113
16:43:24.429424 write(8, "1949400 47.2722 0 0 0 47.6937 0 "..., 118) = 118
16:43:30.057179 write(8, "1949500 47.4865 0 0 0 47.6251 0 "..., 117) = 117



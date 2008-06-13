From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: size of nfsv4 writes
Date: Fri, 13 Jun 2008 15:03:18 -0400
Message-ID: <0123331C-7D55-4228-85B6-F03F79073FA3@oracle.com>
References: <4846C586.1050000@citi.umich.edu> <1212597977.7422.4.camel@localhost> <48471180.8090208@citi.umich.edu> <48519821.1040703@citi.umich.edu> <AC88CD36-0BB2-4053-A595-759500BEA6C3@oracle.com> <4852BA3B.9020308@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11626 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbYFMTEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2008 15:04:14 -0400
In-Reply-To: <4852BA3B.9020308@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 13, 2008, at 2:19 PM, Olga Kornievskaia wrote:
> Chuck Lever wrote:
>> On Jun 12, 2008, at 5:41 PM, Olga Kornievskaia wrote:
>>> Olga Kornievskaia wrote:
>>>> Trond Myklebust wrote:
>>>>> On Wed, 2008-06-04 at 12:40 -0400, Olga Kornievskaia wrote:
>>>>>> While testing NFSv4 performance over the 10GE network, we are  
>>>>>> seeing the following behavior and would like to know if it is  
>>>>>> normal or a bug in the client code.
>>>>>>
>>>>>> The server offers the max_write of 1M. The client mounts the  
>>>>>> server with the "wsize" option of 1M. Yet during the write we  
>>>>>> are seeing that the write size is at most 49K. Why does client  
>>>>>> never come close to 1M limit?
>>>>>
>>>>> I have a feeling that is due to some crap in the VM. I'm currently
>>>>> investigating a situation where it appears we're sending 1  
>>>>> COMMIT for
>>>>> every 1-5 32k WRITEs. This is not a policy that stems from the NFS
>>>>> client, so it would appear that the VM is being silly about  
>>>>> things.
>>>>>
>>>>> I'm specially suspicious of the code in get_dirty_limits() that is
>>>>> setting a limit to the number of dirty pages based on the number  
>>>>> of
>>>>> pages a given BDI has written out in the recent past. As far as  
>>>>> I can
>>>>> see, the intention is to penalise devices that are slow writers,  
>>>>> but in
>>>>> practice it doesn't do that: it penalises the devices that have  
>>>>> the
>>>>> least activity.
>>>>>
>>>> I think we are seeing larger than usual number of COMMIT messages.
>>> Using Chuck's nfs-iostats to monitor an NFS write I can see that  
>>> each operation writes about 830MB. Why is so much small than  
>>> wsize=1M?
>>
>>
>> I assume you mean 830KB.
>>
>> Remember that nfs-iostats reports an average transfer size, so you  
>> may be seeing a lot of 1MB writes on the wire, and just enough  
>> small writes to reduce the average.  Or, the client may not be  
>> writing 1MB at all.
>>
>> You have to look at a network trace to see which.
>>
>> On the other hand, 830KB is still very large.
> Apologizes, yes, it is 830KB. If you say it's an average write then  
> my question is why is NFS breaking down 1M writes into smaller  
> chunks? When I say 1M write I'm referring the the user land (dd)  
> calling write() with 1M buffer.

To understand what is really happening (how often is the client not  
sending a full 1MB?  Are the metrics perhaps lying?) you have to  
capture a network trace and look at what's going on.

We've already been through the problems of looking at such a trace  
with wireshark, but perhaps the text-based equivalent (tethereal?  
tireshark?) will be better about analyzing the packets correctly.   
Then you can use awk or Python to extract a histogram of write sizes.   
You then have immediate graphical evidence of misbehavior.

The client might break up large writes if the VFS breaks them up for  
some reason, or if there is memory pressure that triggers a flush in  
the middle of doing a large 1MB write, or maybe there's a bug...  
looking at the network behavior will give you some clue about where to  
look next.

> I'm trying to understand why NFS has poor write performance. I had 2  
> leads to pursue (1) nfs-iostats shows that each write operation is  
> >100KB smaller than a read operation and (2) I see that during a  
> write nfs-iostats reports fewer operations per second than during a  
> read. The latter can be due to the COMMIT problem.

Yes, and I don't think we know yet whether these are synchronous  
COMMITs (the client waits for the result) or asynchronous COMMITs (the  
client sends the COMMIT request, but keeps writing).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

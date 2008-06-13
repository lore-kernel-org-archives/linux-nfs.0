From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: size of nfsv4 writes
Date: Fri, 13 Jun 2008 14:19:39 -0400
Message-ID: <4852BA3B.9020308@citi.umich.edu>
References: <4846C586.1050000@citi.umich.edu> <1212597977.7422.4.camel@localhost> <48471180.8090208@citi.umich.edu> <48519821.1040703@citi.umich.edu> <AC88CD36-0BB2-4053-A595-759500BEA6C3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47242 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbYFMSTl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 14:19:41 -0400
In-Reply-To: <AC88CD36-0BB2-4053-A595-759500BEA6C3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Jun 12, 2008, at 5:41 PM, Olga Kornievskaia wrote:
>> Olga Kornievskaia wrote:
>>> Trond Myklebust wrote:
>>>> On Wed, 2008-06-04 at 12:40 -0400, Olga Kornievskaia wrote:
>>>>> While testing NFSv4 performance over the 10GE network, we are 
>>>>> seeing the following behavior and would like to know if it is 
>>>>> normal or a bug in the client code.
>>>>>
>>>>> The server offers the max_write of 1M. The client mounts the 
>>>>> server with the "wsize" option of 1M. Yet during the write we are 
>>>>> seeing that the write size is at most 49K. Why does client never 
>>>>> come close to 1M limit?
>>>>
>>>> I have a feeling that is due to some crap in the VM. I'm currently
>>>> investigating a situation where it appears we're sending 1 COMMIT for
>>>> every 1-5 32k WRITEs. This is not a policy that stems from the NFS
>>>> client, so it would appear that the VM is being silly about things.
>>>>
>>>> I'm specially suspicious of the code in get_dirty_limits() that is
>>>> setting a limit to the number of dirty pages based on the number of
>>>> pages a given BDI has written out in the recent past. As far as I can
>>>> see, the intention is to penalise devices that are slow writers, 
>>>> but in
>>>> practice it doesn't do that: it penalises the devices that have the
>>>> least activity.
>>>>
>>> I think we are seeing larger than usual number of COMMIT messages.
>> Using Chuck's nfs-iostats to monitor an NFS write I can see that each 
>> operation writes about 830MB. Why is so much small than wsize=1M?
>
>
> I assume you mean 830KB.
>
> Remember that nfs-iostats reports an average transfer size, so you may 
> be seeing a lot of 1MB writes on the wire, and just enough small 
> writes to reduce the average.  Or, the client may not be writing 1MB 
> at all.
>
> You have to look at a network trace to see which.
>
> On the other hand, 830KB is still very large.
Apologizes, yes, it is 830KB. If you say it's an average write then my 
question is why is NFS breaking down 1M writes into smaller chunks? When 
I say 1M write I'm referring the the user land (dd) calling write() with 
1M buffer.

I'm trying to understand why NFS has poor write performance. I had 2 
leads to pursue (1) nfs-iostats shows that each write operation is 
 >100KB smaller than a read operation and (2) I see that during a write 
nfs-iostats reports fewer operations per second than during a read. The 
latter can be due to the COMMIT problem.

If nfs client is writing less amount of data on each operation and it is 
not able to write fast enough, wouldn't that explain it's poor performance.

Current read performance is 590MB/s
Current write performance is 230MB/s

-O
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>

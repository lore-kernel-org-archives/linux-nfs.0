From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: size of nfsv4 writes
Date: Fri, 13 Jun 2008 12:33:35 -0400
Message-ID: <AC88CD36-0BB2-4053-A595-759500BEA6C3@oracle.com>
References: <4846C586.1050000@citi.umich.edu> <1212597977.7422.4.camel@localhost> <48471180.8090208@citi.umich.edu> <48519821.1040703@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19242 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbYFMQgk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2008 12:36:40 -0400
In-Reply-To: <48519821.1040703@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 12, 2008, at 5:41 PM, Olga Kornievskaia wrote:
> Olga Kornievskaia wrote:
>> Trond Myklebust wrote:
>>> On Wed, 2008-06-04 at 12:40 -0400, Olga Kornievskaia wrote:
>>>> While testing NFSv4 performance over the 10GE network, we are  
>>>> seeing the following behavior and would like to know if it is  
>>>> normal or a bug in the client code.
>>>>
>>>> The server offers the max_write of 1M. The client mounts the  
>>>> server with the "wsize" option of 1M. Yet during the write we are  
>>>> seeing that the write size is at most 49K. Why does client never  
>>>> come close to 1M limit?
>>>
>>> I have a feeling that is due to some crap in the VM. I'm currently
>>> investigating a situation where it appears we're sending 1 COMMIT  
>>> for
>>> every 1-5 32k WRITEs. This is not a policy that stems from the NFS
>>> client, so it would appear that the VM is being silly about things.
>>>
>>> I'm specially suspicious of the code in get_dirty_limits() that is
>>> setting a limit to the number of dirty pages based on the number of
>>> pages a given BDI has written out in the recent past. As far as I  
>>> can
>>> see, the intention is to penalise devices that are slow writers,  
>>> but in
>>> practice it doesn't do that: it penalises the devices that have the
>>> least activity.
>>>
>> I think we are seeing larger than usual number of COMMIT messages.
> Using Chuck's nfs-iostats to monitor an NFS write I can see that  
> each operation writes about 830MB. Why is so much small than wsize=1M?


I assume you mean 830KB.

Remember that nfs-iostats reports an average transfer size, so you may  
be seeing a lot of 1MB writes on the wire, and just enough small  
writes to reduce the average.  Or, the client may not be writing 1MB  
at all.

You have to look at a network trace to see which.

On the other hand, 830KB is still very large.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

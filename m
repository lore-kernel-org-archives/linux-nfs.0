From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: size of nfsv4 writes
Date: Wed, 04 Jun 2008 18:04:48 -0400
Message-ID: <48471180.8090208@citi.umich.edu>
References: <4846C586.1050000@citi.umich.edu> <1212597977.7422.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:22478 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758574AbYFDWEw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 18:04:52 -0400
In-Reply-To: <1212597977.7422.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
> On Wed, 2008-06-04 at 12:40 -0400, Olga Kornievskaia wrote:
>   
>> While testing NFSv4 performance over the 10GE network, we are seeing the 
>> following behavior and would like to know if it is normal or a bug in 
>> the client code.
>>
>> The server offers the max_write of 1M. The client mounts the server with 
>> the "wsize" option of 1M. Yet during the write we are seeing that the 
>> write size is at most 49K. Why does client never come close to 1M limit?
>>     
>
> I have a feeling that is due to some crap in the VM. I'm currently
> investigating a situation where it appears we're sending 1 COMMIT for
> every 1-5 32k WRITEs. This is not a policy that stems from the NFS
> client, so it would appear that the VM is being silly about things.
>
> I'm specially suspicious of the code in get_dirty_limits() that is
> setting a limit to the number of dirty pages based on the number of
> pages a given BDI has written out in the recent past. As far as I can
> see, the intention is to penalise devices that are slow writers, but in
> practice it doesn't do that: it penalises the devices that have the
> least activity.
>
>   
I think we are seeing larger than usual number of COMMIT messages.

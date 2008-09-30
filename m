From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the FastReg	memory
 model
Date: Tue, 30 Sep 2008 13:55:45 -0500
Message-ID: <48E27631.4090202@opengridcomputing.com>
References: <1221564879-85046-6-git-send-email-tom@opengridcomputing.com> <1221564879-85046-7-git-send-email-tom@opengridcomputing.com> <1221564879-85046-8-git-send-email-tom@opengridcomputing.com> <1221564879-85046-9-git-send-email-tom@opengridcomputing.com> <1221564879-85046-10-git-send-email-tom@opengridcomputing.com> <1221564879-85046-11-git-send-email-tom@opengridcomputing.com> <20080924212102.GD10841@fieldses.org> <48DB939E.4090503@opengridcomputing.com> <20080926234006.GA9889@fieldses.org> <48E197ED.6080409@opengridcomputing.com> <20080930184433.GC12268@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Tom Talpey <Thomas.Talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:33018 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752588AbYI3Szq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Sep 2008 14:55:46 -0400
In-Reply-To: <20080930184433.GC12268@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Sep 29, 2008 at 10:07:25PM -0500, Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Thu, Sep 25, 2008 at 08:35:26AM -0500, Tom Tucker wrote:
>>>> J. Bruce Fields wrote:
>>>>> This explanation is helpful, thanks.  It would also be helpful if we
>>>>> could boil down the advice to just a sentence or two for the busy admin.
>>>>> Something like:  unless you have card XYZ and kernel 2.6.y, do *not* use
>>>>> rdma on a network where you cannot trust every machine....
>>>> Would it be better to say, "Do not use RDMA on a network where your   
>>>> policy requires a security model stronger than tcp/auth_unix."
>>> I'm not worried about the case where the security provided is roughly
>>> equivalent to that provided by tcp/auth_unix.
>>>
>>> I'm worried about the non-"Fast Reg" case where I thought you were
>>> saying that the network could access memory other than that meant to
>>> hold rpc data.
>>>
>> Ok, so maybe we could state the security exposure of ALLPHYSICAL instead  
>> of dwelling on the relative differences between the similar exposures of  
>> tcp/auth_unix vs. fastreg?
> 
> Right.  It's all interesting, so I wouldn't cut anything out--but you
> could put off the details to the end; e.g., start with "in situation
> <...>, nfs/rdma provides roughly the same security as nfs over tcp and
> auth_unix (see below for more details)".

Sounds reasonable.

> 
>> I'd also like to get to fastreg as a default at some point.
> 
> OK, good.
> 
>> What's your perspective on the lifetime of bounce buffers, memory  
>> windows, and the other strategies in client?
> 
> I'm ignorant.  Pointer to something else I should read?
> 
> I assume there are similar issues on the client?
>

Sorry, that was a question for Tom Talpey. It's a client specific issue 
since the server only implements ALLPHYSICAL and FAST REG.


> --b.


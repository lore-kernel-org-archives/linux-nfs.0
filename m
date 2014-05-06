Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:53853 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656AbaEFVJO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 17:09:14 -0400
Message-ID: <53694F72.9010007@opengridcomputing.com>
Date: Tue, 06 May 2014 16:09:06 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH V2 RFC 0/3] svcrdma: refactor marshalling logic
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506192730.GK18281@fieldses.org>
In-Reply-To: <20140506192730.GK18281@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/6/2014 2:27 PM, J. Bruce Fields wrote:
> On Tue, May 06, 2014 at 12:46:21PM -0500, Steve Wise wrote:
>> This patch series refactors the NFSRDMA server marshalling logic to
>> remove the intermediary map structures.  It also fixes an existing bug
>> where the NFSRDMA server was not minding the device fast register page
>> list length limitations.
>>
>> I've also made a git repo available with these patches on top of 3.15-rc4:
>>
>> git://git.openfabrics.org/~swise/linux svcrdma-refactor
>>
>> Changes since V1:
>>
>> - fixed regression for devices that don't support FRMRs (see
>>    rdma_read_chunk_lcl())
>>
>> - split patch up for closer review.  However I request it be squashed
>>    before merging as they is not bisectable, and I think these changes
>>    should all be a single commit anyway.
> If it's not split up in a way that's bisectable, then yes, just don't
> bother.

I didn't see a good way to split it up, have it bisectable, and not have 
all the big stuff in one patch.  I think its a little more reviewable in 
these 3 patches, but when I post V3, I'll put it back as an uber patch.  
Hopefully folks can have a look at these 3 patches ignoring the bisect 
issue.    Having said that, the rdma read logic really is better 
reviewed by look at the code after applying the patches.   That's why I 
published a git branch.

Thanks!

Steve.


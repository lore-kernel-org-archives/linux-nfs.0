Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:18980 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135Ab1FJOL0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 10:11:26 -0400
From: <tao.peng@emc.com>
To: <benny@tonian.com>
CC: <bergwolf@gmail.com>, <rees@umich.edu>, <linux-nfs@vger.kernel.org>,
        <honey@citi.umich.edu>
Date: Fri, 10 Jun 2011 10:09:27 -0400
Subject: RE: [PATCH 87/88] Add configurable prefetch size for layoutget
Message-ID: <F19688880B763E40B28B2B462677FBF805BED9D2AC@MX09A.corp.emc.com>
References: <cover.1307464381.git.rees@umich.edu>
 <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
 <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu>
 <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu>
 <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com>
 <4DF139B1.7070106@tonian.com>
 <F19688880B763E40B28B2B462677FBF805BED9D221@MX09A.corp.emc.com>
 <4DF20F07.4090804@tonian.com>
In-Reply-To: <4DF20F07.4090804@tonian.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny,

-----Original Message-----
From: Benny Halevy [mailto:benny@tonian.com] 
Sent: Friday, June 10, 2011 8:33 PM
To: Peng, Tao
Cc: bergwolf@gmail.com; rees@umich.edu; linux-nfs@vger.kernel.org; honey@citi.umich.edu
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget

On 2011-06-10 02:00, tao.peng@emc.com wrote:
> Hi, Benny,
> 
> Cheers,
> -Bergwolf
> 
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Benny Halevy
> Sent: Friday, June 10, 2011 5:23 AM
> To: Peng Tao
> Cc: Jim Rees; linux-nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
> 
> On 2011-06-09 08:07, Peng Tao wrote:
>> Hi, Jim and Benny,
>>
>> On Thu, Jun 9, 2011 at 9:58 PM, Jim Rees <rees@umich.edu> wrote:
>>> Benny Halevy wrote:
>>>
>>>  > My understanding is that layoutget specifies a min and max, and the server
>>>
>>>  There's a min.  What do you consider the max?
>>>  Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?
>>>
>>> The spec doesn't say max, it says "desired."  I guess I assumed the server
>>> wouldn't normally return more than desired.
>> In fact server is returning "desired" length. The problem is that we
>> call pnfs_update_layout in nfs_write_begin, and it will end up setting
>> both minlength and length to page size. There is no space for client
>> to collapse layoutget range in nfs_write_begin.
>>
> 
> That's a different issue.  Waiting with pnfs_update_layout to flush
> time rather than write_begin if the whole page is written would help
> sending a more meaningful desired range as well as avoiding needless
> read-modify-writes in case the application also wrote the whole
> preallocated block.
> [PT] It is also the reason why we want to introduce layout prefetching, to get more segment than the page passed in nfs_write_begin.
> 

Peng, I understand what you want to achieve but the proposed way
just doesn't fly. The server knows better than the client its allocation policies
and it knows better the combined workload of different client and possible
conflicts between them therefore it should be making the ultimate decision
about the actual segment sizes.
[PT] Yes, you are right. Server should know combined workload of all clients and make its decision based on that.
And it always has the right to return more than (or less than) specified in loga_length.
 
That said, the client should indeed do its best to ask for the most appropriate
segments size for its use and we should be making a better job at that.
It's just that blindly asking for more is not a good strategy and requiring
manual admin help to tune the clients is not acceptable.
[PT] yeah, determing the most appropriate is always the hart part. Do you have any suggestions to that?

Thanks,
Tao


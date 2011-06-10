Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:35880 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770Ab1FJMd7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 08:33:59 -0400
Received: by qyg14 with SMTP id 14so1384261qyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2011 05:33:58 -0700 (PDT)
Message-ID: <4DF20F07.4090804@tonian.com>
Date: Fri, 10 Jun 2011 08:33:11 -0400
From: Benny Halevy <benny@tonian.com>
To: tao.peng@emc.com
CC: bergwolf@gmail.com, rees@umich.edu, linux-nfs@vger.kernel.org,
        honey@citi.umich.edu
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu> <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com> <4DF139B1.7070106@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D221@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BED9D221@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

That said, the client should indeed do its best to ask for the most appropriate
segments size for its use and we should be making a better job at that.
It's just that blindly asking for more is not a good strategy and requiring
manual admin help to tune the clients is not acceptable.

Benny

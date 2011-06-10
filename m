Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56435 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab1FJTCp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 15:02:45 -0400
Received: by iyb14 with SMTP id 14so2407898iyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2011 12:02:45 -0700 (PDT)
Message-ID: <4DF26A51.3030805@tonian.com>
Date: Fri, 10 Jun 2011 15:02:41 -0400
From: Benny Halevy <benny@tonian.com>
To: tao.peng@emc.com
CC: rees@umich.edu, bergwolf@gmail.com, linux-nfs@vger.kernel.org,
        honey@citi.umich.edu
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu> <4DF139D0.1080200@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D217@MX09A.corp.emc.com> <4DF20FB3.6030603@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D2AD@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BED9D2AD@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-10 10:17, tao.peng@emc.com wrote:
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Benny Halevy
> Sent: Friday, June 10, 2011 8:36 PM
> To: Peng, Tao
> Cc: rees@umich.edu; bergwolf@gmail.com; linux-nfs@vger.kernel.org; honey@citi.umich.edu
> Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
> 
> On 2011-06-10 01:36, tao.peng@emc.com wrote:
>> Hi, Benny,
>>
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Benny Halevy
>> Sent: Friday, June 10, 2011 5:23 AM
>> To: Jim Rees
>> Cc: Peng Tao; linux-nfs@vger.kernel.org; peter honeyman
>> Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
>>
>> On 2011-06-09 06:58, Jim Rees wrote:
>>> Benny Halevy wrote:
>>>
>>>   > My understanding is that layoutget specifies a min and max, and the server
>>>   
>>>   There's a min.  What do you consider the max?
>>>   Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?
>>>
>>> The spec doesn't say max, it says "desired."  I guess I assumed the server
>>> wouldn't normally return more than desired.
>>
>> No, the server may freely upgrade the returned layout segment by returning
>> a layout for a larger byte range or even returning a RW layout where a READ
>> layout was asked for.
>> [PT] It is true that server can upgrade the layout segment freely. But there is always a price to pay. Server has to be dealing with all kind of clients.
>> If server returns more than being asked for, it may hurt other clients.
> 
> And if all clients ask for more than they need and the server just
> gives it to them, what do you get out of that?
> [PT] We cannot avoid this even if client has automatic layout prefetch algorithem implemented... think about all clients are doing sequential IO...

Right and that's why the server has to be intelligent about it.

Benny

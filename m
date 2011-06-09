Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:37403 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758024Ab1FINcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 09:32:17 -0400
Received: by pxi2 with SMTP id 2so1047058pxi.10
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 06:32:16 -0700 (PDT)
Message-ID: <4DF0CB5D.60000@panasas.com>
Date: Thu, 09 Jun 2011 09:32:13 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu>
In-Reply-To: <20110609114929.GA28157@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 07:49, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   >> But note that this patch doesn't change anything unless you set the sysctl.
>   > there is a default value of 2M. maybe we can set it to page size by
>   > default so other layout are not affected and block layout can let
>   > users set it by hand if they care about performance. does this make
>   > sense?
>   
>   If doing it at all why use a sysctl rather than a mount option?
>   Or maybe coding the logic for prefetching the layout iff sequential
>   access is detected is the right thing to do.
> 
> I would rather see some automatic solution than to add either a sysctl or a
> mount option.  For now you can just drop that patch, as it's not needed for
> basic pnfs block.
> 
> My understanding is that layoutget specifies a min and max, and the server

There's a min.  What do you consider the max?
Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?

> is returning the min.  Trond and Fred believe this should be fixed on the
> server.  

Agreed.

Benny

> Here's the original report of the problem:
> 
> From: Bergwolf
> 
> From the network trace for pnfs, we can see the root cause for slow performance
> is too many small layoutget. In specific, client asks for a layout of only 4K
> pagesize (and server returns 8K due to block size alignment) at each time.
> 
> The total IO time is 256/1.68 = 152 second.
> There are 256*1024/8 = 32768 layoutget for the 256MB file.
> On average, the time spent on each layoutget is 0.00456 second according to the
> trace.
> The total layoutget time is 32768* 0.00456 = 149 second, which takes up about
> 98% of total IO time.
> 
> So we should optimize layoutget's granularity to get better performance. For
> instance, use a configurable prefetch size of 2MB or so.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

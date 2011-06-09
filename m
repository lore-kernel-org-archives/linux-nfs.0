Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61844 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab1FJDHA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 23:07:00 -0400
Received: by iwn34 with SMTP id 34so1850869iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 20:07:00 -0700 (PDT)
Message-ID: <4DF139D0.1080200@tonian.com>
Date: Thu, 09 Jun 2011 14:23:28 -0700
From: Benny Halevy <benny@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu>
In-Reply-To: <20110609135846.GA32565@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 06:58, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   > My understanding is that layoutget specifies a min and max, and the server
>   
>   There's a min.  What do you consider the max?
>   Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?
> 
> The spec doesn't say max, it says "desired."  I guess I assumed the server
> wouldn't normally return more than desired.

No, the server may freely upgrade the returned layout segment by returning
a layout for a larger byte range or even returning a RW layout where a READ
layout was asked for.

Benny

> 
> 18.43.3.  DESCRIPTION
> ...
> 
>    The LAYOUTGET operation returns layout information for the specified
>    byte-range: a layout.  The client actually specifies two ranges, both
>    starting at the offset in the loga_offset field.  The first range is
>    between loga_offset and loga_offset + loga_length - 1 inclusive.
>    This range indicates the desired range the client wants the layout to
>    cover.  The second range is between loga_offset and loga_offset +
>    loga_minlength - 1 inclusive.  This range indicates the required
>    range the client needs the layout to cover.  Thus, loga_minlength
>    MUST be less than or equal to loga_length.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

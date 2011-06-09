Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62042 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817Ab1FIPH5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 11:07:57 -0400
Received: by vws1 with SMTP id 1so1240425vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 08:07:56 -0700 (PDT)
In-Reply-To: <20110609135846.GA32565@merit.edu>
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com>
 <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 9 Jun 2011 23:07:36 +0800
Message-ID: <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Jim and Benny,

On Thu, Jun 9, 2011 at 9:58 PM, Jim Rees <rees@umich.edu> wrote:
> Benny Halevy wrote:
>
>  > My understanding is that layoutget specifies a min and max, and the server
>
>  There's a min.  What do you consider the max?
>  Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?
>
> The spec doesn't say max, it says "desired."  I guess I assumed the server
> wouldn't normally return more than desired.
In fact server is returning "desired" length. The problem is that we
call pnfs_update_layout in nfs_write_begin, and it will end up setting
both minlength and length to page size. There is no space for client
to collapse layoutget range in nfs_write_begin.

>
> 18.43.3.  DESCRIPTION
> ...
>
>   The LAYOUTGET operation returns layout information for the specified
>   byte-range: a layout.  The client actually specifies two ranges, both
>   starting at the offset in the loga_offset field.  The first range is
>   between loga_offset and loga_offset + loga_length - 1 inclusive.
>   This range indicates the desired range the client wants the layout to
>   cover.  The second range is between loga_offset and loga_offset +
>   loga_minlength - 1 inclusive.  This range indicates the required
>   range the client needs the layout to cover.  Thus, loga_minlength
>   MUST be less than or equal to loga_length.
>



-- 
Thanks,
-Bergwolf

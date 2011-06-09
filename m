Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61884 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab1FJDGE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 23:06:04 -0400
Received: by iwn34 with SMTP id 34so1850391iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 20:06:02 -0700 (PDT)
Message-ID: <4DF139B1.7070106@tonian.com>
Date: Thu, 09 Jun 2011 14:22:57 -0700
From: Benny Halevy <benny@tonian.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu> <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com>
In-Reply-To: <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 08:07, Peng Tao wrote:
> Hi, Jim and Benny,
> 
> On Thu, Jun 9, 2011 at 9:58 PM, Jim Rees <rees@umich.edu> wrote:
>> Benny Halevy wrote:
>>
>>  > My understanding is that layoutget specifies a min and max, and the server
>>
>>  There's a min.  What do you consider the max?
>>  Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?
>>
>> The spec doesn't say max, it says "desired."  I guess I assumed the server
>> wouldn't normally return more than desired.
> In fact server is returning "desired" length. The problem is that we
> call pnfs_update_layout in nfs_write_begin, and it will end up setting
> both minlength and length to page size. There is no space for client
> to collapse layoutget range in nfs_write_begin.
> 

That's a different issue.  Waiting with pnfs_update_layout to flush
time rather than write_begin if the whole page is written would help
sending a more meaningful desired range as well as avoiding needless
read-modify-writes in case the application also wrote the whole
preallocated block.

Benny

>>
>> 18.43.3.  DESCRIPTION
>> ...
>>
>>   The LAYOUTGET operation returns layout information for the specified
>>   byte-range: a layout.  The client actually specifies two ranges, both
>>   starting at the offset in the loga_offset field.  The first range is
>>   between loga_offset and loga_offset + loga_length - 1 inclusive.
>>   This range indicates the desired range the client wants the layout to
>>   cover.  The second range is between loga_offset and loga_offset +
>>   loga_minlength - 1 inclusive.  This range indicates the required
>>   range the client needs the layout to cover.  Thus, loga_minlength
>>   MUST be less than or equal to loga_length.
>>
> 
> 
> 

-- 
Benny Halevy
CTO, Tonian Inc.

Tel: +972-54-802-8340
benny@tonian.com

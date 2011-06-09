Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54793 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab1FIGI3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 02:08:29 -0400
Received: by pwi15 with SMTP id 15so587944pwi.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2011 23:08:29 -0700 (PDT)
Message-ID: <4DF0635B.9050004@panasas.com>
Date: Thu, 09 Jun 2011 02:08:27 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu>	<09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>	<4DEED80A.4000102@panasas.com>	<20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
In-Reply-To: <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-08 03:15, Peng Tao wrote:
> On 6/8/11, Jim Rees <rees@umich.edu> wrote:
>> Benny Halevy wrote:
>>
>>   NAK.
>>   This affects all layout types.  In particular it is undesired
>>   for write layouts that extend the file with the objects layout.
>>   The server can extend the layout segments range
>>   over what the client requested so why would the client
>>   ask for artificially large layouts?
>>
>> This has actually been the subject of some debate over Thursday night
>> beers.  The problem we're trying to solve is that the client is spending 98%
>> of its time in layoutget.  This patch gives us something like a 10x
>> speedup.  But many of us think it's not the right fix.  I suggest we discuss
>> next week.
>>

Sure.

>> But note that this patch doesn't change anything unless you set the sysctl.
> there is a default value of 2M. maybe we can set it to page size by
> default so other layout are not affected and block layout can let
> users set it by hand if they care about performance. does this make
> sense?

If doing it at all why use a sysctl rather than a mount option?
Or maybe coding the logic for prefetching the layout iff sequential
access is detected is the right thing to do.

Benny

>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 

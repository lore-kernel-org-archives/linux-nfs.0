Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41938 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932117Ab0I3PeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 11:34:21 -0400
Message-ID: <4CA4ADFA.2090807@panasas.com>
Date: Thu, 30 Sep 2010 17:34:18 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: pnfs-all-latest client crash
References: <20100921164211.GK26473@fieldses.org> <4C98FCC3.50803@panasas.com> <20100921190108.GA4385@fieldses.org> <4CA4ABED.7080706@panasas.com> <20100930152944.GA6598@fieldses.org>
In-Reply-To: <20100930152944.GA6598@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-30 17:29, J. Bruce Fields wrote:
> On Thu, Sep 30, 2010 at 05:25:33PM +0200, Benny Halevy wrote:
>> On 2010-09-21 21:01, J. Bruce Fields wrote:
>>> On Tue, Sep 21, 2010 at 08:43:15PM +0200, Benny Halevy wrote:
>>>> On 2010-09-21 18:42, J. Bruce Fields wrote:
>>>>> I get the following on pnfs-all-latest, while doing a non-pnfs 4.1 mount.
>>>>
>>>> Bruce, can you please provide you .config file?
>>>> >From the registers value it's possible the calldata is used
>>>> after free...
>>>
>>> Yep.  I ran a 'make oldconfig' on the appended and built from that.
>>>
>>> We've seen poisoning in trond's latest for-next as well.  Which I don't
>>> think you're including.  But I'll add linux-nfs to the cc for that.
>>>
>>> --b.
>>>
>>> #
>>> # Automatically generated make config: don't edit
>>> # Linux kernel version: 2.6.36-rc4
>>> # Wed Sep 15 14:57:18 2010
>>> #
> ...
>>> # CONFIG_INPUT_TABL
>>
>> Looks like the message got truncated :-(
> 
> Huh.  Sorry about that!

And I presume you config all pNFS options as 'N', right?

Benny

> 
> --b.
> 

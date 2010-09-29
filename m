Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32864 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752158Ab0I2Pex (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 11:34:53 -0400
Message-ID: <4CA35C9B.5050307@panasas.com>
Date: Wed, 29 Sep 2010 17:34:51 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: pnfs-all-latest client crash
References: <20100921164211.GK26473@fieldses.org> <4C98FCC3.50803@panasas.com> <20100921190108.GA4385@fieldses.org> <20100928155117.GK24465@fieldses.org>
In-Reply-To: <20100928155117.GK24465@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-28 17:51, J. Bruce Fields wrote:
> On Tue, Sep 21, 2010 at 03:01:08PM -0400, J. Bruce Fields wrote:
>> On Tue, Sep 21, 2010 at 08:43:15PM +0200, Benny Halevy wrote:
>>> On 2010-09-21 18:42, J. Bruce Fields wrote:
>>>> I get the following on pnfs-all-latest, while doing a non-pnfs 4.1 mount.
>>>
>>> Bruce, can you please provide you .config file?
>>> >From the registers value it's possible the calldata is used
>>> after free...
>>
>> Yep.  I ran a 'make oldconfig' on the appended and built from that.
>>
>> We've seen poisoning in trond's latest for-next as well.  Which I don't
>> think you're including.  But I'll add linux-nfs to the cc for that.
> 
> By the way, nightly tests on pnfs code havn't been running due to lack
> of upstream writeback fixes:
> 	b76b4014f9d988d2412b873e4d4c13c7f9afc4e4
> and
> 	6628bc74f1aa9c35dd386320bf7ec04f12edb1b3
> 
> (both in -rc4, I believe).
> 
> --b.

OK, now that I've rebased onto -rc6 they should be there.

Benny

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58767 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754534Ab0IMMpR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 08:45:17 -0400
Message-ID: <4C8E1CD9.1040404@panasas.com>
Date: Mon, 13 Sep 2010 14:45:13 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@panasas.com>, Andy Adamson <andros@netapp.com>
Subject: Re: [RFC 1/3] SQUASHME: Generalize the device cache so it can be
 used by all layouts
References: <4C8D0759.6090201@panasas.com>	<4C8D07D5.6010006@panasas.com>	<1284320533.7880.131.camel@heimdal.trondhjem.org>	<4C8DF3E5.4050108@panasas.com> <AANLkTinJXRe7QWhPD5OV9KA9uUribFXwSenmbJyqnzk1@mail.gmail.com>
In-Reply-To: <AANLkTinJXRe7QWhPD5OV9KA9uUribFXwSenmbJyqnzk1@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/13/2010 02:16 PM, Fred Isaman wrote:
> On Mon, Sep 13, 2010 at 2:50 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> This doesn't look like it needs to be part of the initial single-layout
>>> submission. Why is it being labelled as a squashme?
>>>
>>> Trond
>>
>> No, this is a device_id cache per nfs-client it is part of the initial
>> getdeviceinfo call. Many "single-layout" may refer to the same device_id
>> therefor it is cached so the long getdeviceinfo call can be done only once.
>>
>> Cheers
>> Boaz
> 
> I agree.  I'll roll it into the next submission.
> 
> Fred

Thanks Fred. I would like if you can report that it actually works, as I have
not tested it.

BTW. For the objects I have decided to not keep a reference on the device_id
during the lseg life span, but just keep a reference to the underlying osd_device
so the device_id can be removed from the cache but still be used by a 
layout_seg/io_state. I have tested and it works and apparently it unmounts
cleanly without any reference leaks. Will post patches later once the new API
hits Benny's tree.

Thanks
Boaz

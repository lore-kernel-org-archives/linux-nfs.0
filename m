Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f177.google.com ([209.85.192.177]:51873 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaGQNTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 09:19:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so3116077pdj.22
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 06:19:02 -0700 (PDT)
Message-ID: <53C7CD42.3030609@gmail.com>
Date: Thu, 17 Jul 2014 21:18:58 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix bad reserving space for encoding rdattr_error
References: <53B8C3D3.7080201@gmail.com> <20140707181556.GC8630@fieldses.org> <20140710105451.GA23266@infradead.org> <20140711201129.GB11931@fieldses.org> <20140714095944.GA25481@infradead.org> <20140716220629.GH2397@fieldses.org>
In-Reply-To: <20140716220629.GH2397@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/17/2014 06:06, J. Bruce Fields wrote:
> On Mon, Jul 14, 2014 at 02:59:44AM -0700, Christoph Hellwig wrote:
>> On Fri, Jul 11, 2014 at 04:11:29PM -0400, J. Bruce Fields wrote:
>>>> On Mon, Jul 07, 2014 at 02:15:56PM -0400, J. Bruce Fields wrote:
>>>>>> -	p = xdr_reserve_space(xdr, 6);
>>>>>> +	p = xdr_reserve_space(xdr, 20);
>>>>
>>>> Can we please convert all these magic numbers to expressions adding up
>>>> sizeofs or where that doesn't fit use #defines?
>>>
>>> So, this would be 
>>>
>>> 	xdr_reserve_space(xdr, 5 * sizeof(be32));
>>>
>>> ?  I guess that'd be OK.
>>
>> Yes, that makes a lot more sense.
> 
> Sounds reasonable to me.  I'm not volunteering for now.

I will try to converting those codes today.

thanks,
Kinglong Mee

> 
>> I'm still hoping to make progress
>> on my krpcgen one day..
> 
> OK, good luck....
> 
> --b.
> .
> 

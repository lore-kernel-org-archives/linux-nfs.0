Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f179.google.com ([74.125.82.179]:43951 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbaHLK5L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 06:57:11 -0400
Received: by mail-we0-f179.google.com with SMTP id u57so9751557wes.24
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 03:57:09 -0700 (PDT)
Message-ID: <53E9F303.2030509@gmail.com>
Date: Tue, 12 Aug 2014 13:57:07 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: pnfs: factor GETDEVICEINFO implementations
References: <1407787617-26050-1-git-send-email-hch@lst.de> <53E9DFDD.50405@gmail.com> <20140812095242.GA6842@lst.de>
In-Reply-To: <20140812095242.GA6842@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/12/2014 12:52 PM, Christoph Hellwig wrote:
> On Tue, Aug 12, 2014 at 12:35:25PM +0300, Boaz Harrosh wrote:
>>> This is mostly done by moving well tested code from the file and block
>>> layout drivers to common code.  I've only tested it using the block
>>> layout driver, so testing with the other layouts would be greatly
>>> appreciated.  I'm mostly concerned about the object layout driver as
>>> it had significant differences and missing bug fixes compared to the
>>> others.
>>>
>> Hi Christoph
>>
>> Please say what BUGs have you seen in object-layout-drive?
> 
> I've not seen actual bugs, but it's been missing various minor bug
> fixes that were applied to the file layout version.
> 
>> Do you have this on a public tree somewhere? I would like to test it?
> 
> I didn't bother for just those few patches, but I've created a "getdeviceinfo"
> branch at git://git.infradead.org/users/hch/pnfs.git
> 
> 

Thanks Christoph, I'll give it a go and report. (But not today)

Boaz


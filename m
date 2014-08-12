Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:62855 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbaHLJf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 05:35:29 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so5537208wib.10
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 02:35:28 -0700 (PDT)
Message-ID: <53E9DFDD.50405@gmail.com>
Date: Tue, 12 Aug 2014 12:35:25 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: pnfs: factor GETDEVICEINFO implementations
References: <1407787617-26050-1-git-send-email-hch@lst.de>
In-Reply-To: <1407787617-26050-1-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/11/2014 11:06 PM, Christoph Hellwig wrote:
> This series adds a common implementation of the GETDEVICELIST operation,
> and switches the block layout driver to use the generic device id cache.
> 
> This is mostly done by moving well tested code from the file and block
> layout drivers to common code.  I've only tested it using the block
> layout driver, so testing with the other layouts would be greatly
> appreciated.  I'm mostly concerned about the object layout driver as
> it had significant differences and missing bug fixes compared to the
> others.
> 
Hi Christoph

Please say what BUGs have you seen in object-layout-drive?

It should be noted that pnfs-obj's GETDEVICEINFO is very simple and will
never ever reach a full page. So the code was more simple, that's all.

Do you have this on a public tree somewhere? I would like to test it?

Thanks
Boaz

> Note that the last patch requires my previous block layout series, but
> the others should work fine without it.
> 
> This work was sponsored by NetApp, Inc.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> .
> 


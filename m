Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:57255 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab1H2VXn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 17:23:43 -0400
Message-ID: <4E5C01BF.1050402@panasas.com>
Date: Mon, 29 Aug 2011 14:16:47 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <benny@tonian.com>,
        <linux-nfs@vger.kernel.org>, Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH v2 1/3] pNFS: recoalesce when ld write pagelist fails
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com> <1313197213-1651-2-git-send-email-bergwolf@gmail.com> <CA+a=Yy5V-JpEy_aJ6=H5=y=GBsoDGL-TDbPZkaVmT0DxEYhLjA@mail.gmail.com> <4E5859C6.5000807@panasas.com> <CA+a=Yy7Nh7eiyuWPcbnJNR+12ypH9pMSjUr8h4AgJW0mPDubXA@mail.gmail.com>
In-Reply-To: <CA+a=Yy7Nh7eiyuWPcbnJNR+12ypH9pMSjUr8h4AgJW0mPDubXA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/27/2011 03:47 AM, Peng Tao wrote:
> Hi, Boaz,
> 
> On Sat, Aug 27, 2011 at 10:43 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> My only concern about the patch is here. If we fail at
>>> nfs_page_async_flush(), is it enough to just call nfs_set_pageerror()
>>> on the page? Do we need to redirty the page as well, and maybe some
>>> other things?
>>>
>>
>> Hum? That's a very good question. nfs_end_page_writeback above does
>> an end_page_writeback(), which does test_clear_page_writeback().
>> Now in nfs_page_async_flush() you are adding the page back to the nfs writeback
>> queue. So the question is when does test_set_page_writeback() is called?
>> If it is called as part of the re-issue of write by NFS then you are
>> fine because you clear it here but it will be set later on. But if
>> it was done on entry into the queue. At the original sight of the call to
>> nfs_page_async_flush(). Then it will not be set again and it might confuse
>> the VFS since we will be re-clearing a cleared bit.
>
> nfs_set_page_tag_locked() and nfs_set_page_writeback() are called
> inside nfs_page_async_flush(), so we need to call
> nfs_clear_page_tag_locked() and nfs_end_page_writeback() before
> invoking nfs_page_async_flush(). 

OK grate, so you answered my question, that's good then.

> But I am not quite sure about how to
> handle nfs_page_async_flush() failure properly here (e.g., OOM). If we
> don't re-dirty the page, will it break NFS writeback assumptions?
> 

Hmm, that one is tough. (From the frying-pan into the fire).

Lets add a big FIXME: for now. And later after lots of testing and error
injection we might just check nfs_page_async_flush() return code and
manually re-dirty the page on failure.

> Thanks,
> Tao
>>

Thanks
Boaz

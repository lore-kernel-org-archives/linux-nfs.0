Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f179.google.com ([74.125.82.179]:34522 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab3JMMof (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 08:44:35 -0400
Received: by mail-we0-f179.google.com with SMTP id w61so5876602wes.24
        for <linux-nfs@vger.kernel.org>; Sun, 13 Oct 2013 05:44:33 -0700 (PDT)
Message-ID: <525A95AE.7060008@primarydata.com>
Date: Sun, 13 Oct 2013 15:44:30 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map super_blocks
 to devid major identifiers
References: <52447EA0.7070004@primarydata.com> <1380220831-13136-1-git-send-email-bhalevy@primarydata.com> <20131011195608.GA18634@infradead.org> <525A399C.5040405@primarydata.com> <20131013110820.GA31153@infradead.org>
In-Reply-To: <20131013110820.GA31153@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-13 14:08, Christoph Hellwig wrote:
> On Sun, Oct 13, 2013 at 09:11:40AM +0300, Benny Halevy wrote:
>> On 2013-10-11 22:56, Christoph Hellwig wrote:
>>> On Thu, Sep 26, 2013 at 02:40:31PM -0400, Benny Halevy wrote:
>>>> From: Benny Halevy <bhalevy@panasas.com>
>>>
>>> This is entirely unessecary.  Just make sure all layouts set the sbid
>>> field in getdevicelist to the s_dev value of the filesystem and you
>>> can just use user_get_super.
>>
>> That's true for filesystmes that have a meaningful s_dev, unlike exofs,
>> but this functionality can be added later respectively.
> 
> Even exofs has a s_dev from the anon dev_T allocator.  Given that
> layouts aren't supposed to surived over reboots of the server I don't
> see a problem with it.

As far as I can see, exofs doesn't actually doing that.
Currently exofs_fill_super sets s_dev = 0;
Boaz, did I miss anything?

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

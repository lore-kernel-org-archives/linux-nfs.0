Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:48799 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757254AbaHGNqI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 09:46:08 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so10354254igb.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 Aug 2014 06:46:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2512424DBC01FD48843E938C780FA97C1D160F928F@MX23A.corp.emc.com>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de>
 <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
 <20140807112537.GA3437@lst.de> <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com>
 <2512424DBC01FD48843E938C780FA97C1D160F928F@MX23A.corp.emc.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 7 Aug 2014 21:45:47 +0800
Message-ID: <CA+a=Yy7Ov0abo+teHf1MSKqXB+7if_TSaEowAUTz421S8t4==g@mail.gmail.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than
 page size
To: "faibish, sorin" <faibish_sorin@emc.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 7, 2014 at 8:56 PM, faibish, sorin <faibish_sorin@emc.com> wrote:
> Why don't you send a patch?
>
I can't be sure what I proposed is correct and I don't have any server
to test against.

> -----Original Message-----
> From: Peng Tao [mailto:bergwolf@gmail.com]
> Sent: Thursday, August 07, 2014 7:52 AM
> To: Christoph Hellwig
> Cc: Trond Myklebust; linuxnfs; faibish, sorin
> Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than page size
>
> On Thu, Aug 7, 2014 at 7:25 PM, Christoph Hellwig <hch@lst.de> wrote:
>> On Thu, Aug 07, 2014 at 06:43:14PM +0800, Peng Tao wrote:
>>> So this kills EMC server support.
>>
>> Given the state the code  claiming support for any server is a large
>> exaggeration..
>>
>>> Can you please share what kind of
>>> badly deadlock you saw with large block size support?
>>
>> The read-modify write code (which I'll remove later) can lock arbitary
>> numbers of additional pages from the writeback back code without doing
>> a trylock, which is required for doing this in page writeback.  Note
>> that it's not a deadlock, but I can also trivіally corrupt data in
>> those pages as it doesn't lock against them, you just need a race
>> window where it's modified after writeback has been started for a
>> large extents, which isn't too hard to hit with tools like fsstress.
>>
> Is it bl_find_get_zeroing_page() you are concerning about? I was hoping page flags can tell if some other threads are flushing the same page. And the extra page is always locked before readin or zeroed, after which the page is marked uptodate before unlocking. So the problem is that a page that is being written back gets modified by a new writer, is it correct? How about marking it writeback before unlocking in bl_find_get_zeroing_page()? That should keep new writers from modifying it concurrently.

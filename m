Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35066 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964842AbbLRTuK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2015 14:50:10 -0500
Received: by mail-oi0-f54.google.com with SMTP id l9so36344566oia.2
        for <linux-nfs@vger.kernel.org>; Fri, 18 Dec 2015 11:50:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHRPZ9Yd6iY7UTD5mEgCJH0T8usLgZfwXr+3JxdpidVMA@mail.gmail.com>
References: <1448389782-99578-1-git-send-email-kolga@netapp.com>
	<CAN-5tyGozh3KhyHEfsh3QPA_YvW1++Kg7jLhz0RP8e0Niq4tUQ@mail.gmail.com>
	<CAN-5tyHRPZ9Yd6iY7UTD5mEgCJH0T8usLgZfwXr+3JxdpidVMA@mail.gmail.com>
Date: Fri, 18 Dec 2015 14:50:09 -0500
Message-ID: <CAHQdGtQiqUvYaQQ5Zc2z8qDv-XeAtVeZPL5HDM7KAd8jQjxWHA@mail.gmail.com>
Subject: Re: [PATCH Version 2 0/2] Adding to tracepoints
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 18, 2015 at 1:52 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Trond,
>
> I have had wireshark accept the patch to display the crc32 hash of the
> stateid's other field to match the output in the tracepoints. Can you
> please provide feedback about the proposed additions to tracepoints?
>

The patches looked OK to me. They do change message formats, but since
you are just appending to existing tracepoints, then that is ok.

I'm queuing these for the Linux 4.5 merge window.

> Thank you.
>
> On Wed, Dec 9, 2015 at 3:59 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Trond,
>>
>> Any thoughts on the patches?
>>
>> Thank you.
>>
>> On Tue, Nov 24, 2015 at 1:29 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>> First patch adds stateid information to tracepoints (openstateid, delegation
>>> stateid, and locking stateid). Version 2 of this patch fixes two things from
>>> the previous version: (1) typo in printout missing ":" in one stateid, (2)
>>> close tracepoint should take stateid from the args instead of the state passed
>>> in as state's stateid could be delegation stateid.
>>>
>>> Second patch adds a new tracepoint nfs_cached_open()
>>>
>>> Olga Kornievskaia (2):
>>>   Adding stateid information to tracepoints
>>>   Adding tracepoint to cached open
>>>
>>>  fs/nfs/internal.h  |   9 ++
>>>  fs/nfs/nfs4proc.c  |  15 +--
>>>  fs/nfs/nfs4trace.h | 294 ++++++++++++++++++++++++++++++++++++++++++++++++-----
>>>  3 files changed, 286 insertions(+), 32 deletions(-)
>>>
>>> --
>>> 1.8.3.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

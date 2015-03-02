Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:46958 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbbCBWBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 17:01:19 -0500
Received: by igbhl2 with SMTP id hl2so21489306igb.5
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 14:01:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGY=gA8zCfnQCKMmvV2TDDGHBHVt+0Df9sj2mtytJpA5g@mail.gmail.com>
References: <CAN-5tyEYVSNeBzN8Ok=vmjxrMj-fhYQSL=ny4rqvx4r5TQNLyg@mail.gmail.com>
	<CAHQdGtQxR_VT+8g5oNLHcsBOKcWVG6j7c+A2rQBO7VkP9E6WPA@mail.gmail.com>
	<CAN-5tyGY=gA8zCfnQCKMmvV2TDDGHBHVt+0Df9sj2mtytJpA5g@mail.gmail.com>
Date: Mon, 2 Mar 2015 17:01:18 -0500
Message-ID: <CAN-5tyFq4=yvyYfOab_kppYY7Y5=Zt1EV05pWbkRcaLSEe6mzA@mail.gmail.com>
Subject: Re: buggy CLOSE in the "testing" branch
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 2, 2015 at 3:53 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Mon, Mar 2, 2015 at 3:47 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> Hi Olga,
>>
>> On Mon, Mar 2, 2015 at 3:15 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> Hi folks,
>>>
>>> I'm experiencing that CLOSE uses a delegation stateid instead of the
>>> open stateid which I think is what the spec says. Server replies with
>>> BAD_STATEID.
>>>
>>> Is this a bug or did I misread the spec? Thanks.
>>>
>>
>> That would be a client bug. Do you have a reproducer?
>
> Yep. Just cat a (2nd) file after mount (i.e.., a file needs to have a
> delegation). A CLOSE will use a delegation stateid. Problem is seenl
> on the network trace. It will also leads to failure on unmount with
> CLIENTID_BUSY because there is still an open state that client never
> released. Please note that both "cat" and "unmount" will "succeed"
> from the user's perspective. Thus, unless testing also looks at the
> network trace, this failure will never be caught.

Anna pointed me at the commit 566fcec60. It seems to be that's what
broke it as it removed the use of openstateid for the stateid arg. But
I really don't understand the necessity of the patch. CLOSE must
always use the openstateid. Therefore it doesn't need to worry that
stateid is changed from openstateid to delegation stateid or locking
stateid. It should just use the openstateid as it did before.

>
>
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer, PrimaryData
>> trond.myklebust@primarydata.com

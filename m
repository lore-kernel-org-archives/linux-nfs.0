Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:44760 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbCBW3k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 17:29:40 -0500
Received: by mail-vc0-f171.google.com with SMTP id hy10so2590276vcb.2
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 14:29:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFq4=yvyYfOab_kppYY7Y5=Zt1EV05pWbkRcaLSEe6mzA@mail.gmail.com>
References: <CAN-5tyEYVSNeBzN8Ok=vmjxrMj-fhYQSL=ny4rqvx4r5TQNLyg@mail.gmail.com>
	<CAHQdGtQxR_VT+8g5oNLHcsBOKcWVG6j7c+A2rQBO7VkP9E6WPA@mail.gmail.com>
	<CAN-5tyGY=gA8zCfnQCKMmvV2TDDGHBHVt+0Df9sj2mtytJpA5g@mail.gmail.com>
	<CAN-5tyFq4=yvyYfOab_kppYY7Y5=Zt1EV05pWbkRcaLSEe6mzA@mail.gmail.com>
Date: Mon, 2 Mar 2015 17:29:39 -0500
Message-ID: <CAHQdGtR-+_ThSdeM-X+X-b1-uuJ+y875gnR0nxbmJreOOQjHFQ@mail.gmail.com>
Subject: Re: buggy CLOSE in the "testing" branch
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 2, 2015 at 5:01 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Mon, Mar 2, 2015 at 3:53 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Mon, Mar 2, 2015 at 3:47 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> Hi Olga,
>>>
>>> On Mon, Mar 2, 2015 at 3:15 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> Hi folks,
>>>>
>>>> I'm experiencing that CLOSE uses a delegation stateid instead of the
>>>> open stateid which I think is what the spec says. Server replies with
>>>> BAD_STATEID.
>>>>
>>>> Is this a bug or did I misread the spec? Thanks.
>>>>
>>>
>>> That would be a client bug. Do you have a reproducer?
>>
>> Yep. Just cat a (2nd) file after mount (i.e.., a file needs to have a
>> delegation). A CLOSE will use a delegation stateid. Problem is seenl
>> on the network trace. It will also leads to failure on unmount with
>> CLIENTID_BUSY because there is still an open state that client never
>> released. Please note that both "cat" and "unmount" will "succeed"
>> from the user's perspective. Thus, unless testing also looks at the
>> network trace, this failure will never be caught.
>
> Anna pointed me at the commit 566fcec60. It seems to be that's what
> broke it as it removed the use of openstateid for the stateid arg. But
> I really don't understand the necessity of the patch. CLOSE must
> always use the openstateid. Therefore it doesn't need to worry that
> stateid is changed from openstateid to delegation stateid or locking
> stateid. It should just use the openstateid as it did before.
>

Doh! Yes, the change to ->stateid is wrong. I must have been on borken
autopilot...

The reason for the patch itself is to ensure the seqid hasn't changed.
It has nothing to do with delegation stateids or locking.
Can either one of you please send a patch to fix up 566fcec60? Please
note that we also need to change the comparison in nfs4_close_done to
match the copy in nfs4_close_prepare.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

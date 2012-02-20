Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:65432 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab2BTTdQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 14:33:16 -0500
Received: by wics10 with SMTP id s10so3071078wic.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2012 11:33:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F429BF4.9050409@candelatech.com>
References: <4F4194C4.40104@yahoo.com>
	<1329760844.2834.1.camel@lade.trondhjem.org>
	<20120220182709.GA22899@umich.edu>
	<1329762949.5151.8.camel@lade.trondhjem.org>
	<4F429450.5080502@candelatech.com>
	<1329764945.5151.13.camel@lade.trondhjem.org>
	<4F429BF4.9050409@candelatech.com>
Date: Mon, 20 Feb 2012 14:33:15 -0500
Message-ID: <CAHVgHyWvazAA-J4ZAdwf7ZqCS8EkP38ose=QMz5BrrDTdnhorA@mail.gmail.com>
Subject: Re: [OOPS] NFS dereferenced NULL pointer with 3.2.6 kernel.
From: Andy Adamson <androsadamson@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>,
        Chris Rankin <rankincj@yahoo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll test ACLs with the patch this week at Connectathon.

-->Andy

On Mon, Feb 20, 2012 at 2:16 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 02/20/2012 11:09 AM, Myklebust, Trond wrote:
>>
>> On Mon, 2012-02-20 at 10:43 -0800, Ben Greear wrote:
>>>
>>> On 02/20/2012 10:35 AM, Myklebust, Trond wrote:
>>>>
>>>> On Mon, 2012-02-20 at 13:27 -0500, Jim Rees wrote:
>>>>>
>>>>> Myklebust, Trond wrote:
>>>>>
>>>>>    It's a known bug. There is a fix at
>>>>>
>>>>>
>>>>>  http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=commit;h=331818f1c468a24e581aedcbe52af799366a9dfe
>>>>>
>>>>> Shouldn't this be in stable by now?  You sent it Feb 3, and there have
>>>>> been
>>>>> two stable releases since then.
>>>>
>>>>
>>>> I've been waiting for Andy to get back from vacation. We've already sent
>>>> one buggy patch to stable...
>>>>
>>>
>>> It's still not in 3.3-rc either, at least put it there so others
>>> can test it?
>>
>>
>> 3.3-rc is _NOT_ a place to put patches for testing... You test the
>> patches _BEFORE_ you send them upstream.
>
>
> Ok, but seems like it would be pretty lame to release 3.3 with this known
> crash bug.
>
> And, though I haven't done any thorough NFS testing, I could hit the
> bug every time before I applied the patch..and since I applied it,
> I have not had any problems.
>
> So, it has been tested at least a bit.
>
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

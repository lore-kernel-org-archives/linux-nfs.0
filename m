Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37993 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbCZUNa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2015 16:13:30 -0400
Received: by igbqf9 with SMTP id qf9so2445770igb.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2015 13:13:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55143D14.4020701@RedHat.com>
References: <CAL8eLxVyJYiSmVL1FP6eFNmMQCQZRHO+rYP5Wvv9cyZ+DU_jiQ@mail.gmail.com>
	<CAL8eLxW7_B=_B-h2Ph_dgWf4nmcNmG8DZoi7BqPYc3y95EcMTg@mail.gmail.com>
	<55143D14.4020701@RedHat.com>
Date: Fri, 27 Mar 2015 01:43:29 +0530
Message-ID: <CAL8eLxXajyuPpeZSQsvU8+5ukjcxs=0wvZBByhb2p2DtLWja2A@mail.gmail.com>
Subject: Re: Fwd: nfs.5: Add addr mount option for all nfs versions
From: Abhijit Pal <21.abhijit@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Steve,

Thanks for your reply. I was wondering if the fix is required in the
man page by just adding this option for nfs mount, or there is a need
to fix the mount system call.

In either case I can send the patch. Please advise which would be appropriate.

Thanks
Abhijit

On Thu, Mar 26, 2015 at 10:38 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 03/24/2015 08:19 AM, Abhijit Pal wrote:
>> Hello linux-nfs team,
>>
>> Thank you for giving your attention and time to my query.
>>
>> Wanted to get an insight about a problem regarding nfs mount using the
>> system call mount(2) which was reported by one of the user in
>> "StackOverflow".
>>
>> The URL for the problem statement and the accepted solution is:
>> http://stackoverflow.com/questions/28350912/nfs-mount-system-call-in-linux
>>
>> After going through the kernel code(v 3.18.6), I have posted an answer
>> which worked for the user and was accepted. Was thinking if you can
>> guide me if the accepted solution is indeed a bug or not. And if the
>> solution is acceptable would request you to kindly let me know the
>> process, so that I can send a patch for updating the nfs(5) man page.
>>
> Mail the patch to this list following these guidelines
>    https://www.kernel.org/doc/Documentation/SubmittingPatches
>
> steved.
>

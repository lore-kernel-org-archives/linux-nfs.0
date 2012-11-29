Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:34780 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab2K2NrD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 08:47:03 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so14469894oag.19
        for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2012 05:47:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B329B2A@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAGRr-NiRkkhoVG4ss5WG7RXXOUWQ5dcOaVAxbQ2yA2c1NbPjKw@mail.gmail.com>
 <CAA4Z2ZQHAvZoUE6h9aqHSZwWF8jvY5QSYai0nXK9gZr6-BN+qA@mail.gmail.com>
 <CAGRr-NjKsSGoL5P8n8nsfk3eoAY8zZt+h1K6rU19cLitTD78uw@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA90B329B2A@SACEXCMBX04-PRD.hq.netapp.com>
From: =?UTF-8?B?xYF1a2FzeiBUYXN6?= <lukasz@tasz.eu>
Date: Thu, 29 Nov 2012 14:46:31 +0100
Message-ID: <CAGRr-Niowy4W6wmqjCHesv9r66B0Ok2kha-7=xBp69gksaXt-A@mail.gmail.com>
Subject: Re: nfs performance - idea.
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Adrien Kunysz <adk@acunu.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, thanks a lot for answer,

looks then even better! so to be 100% sure it good to traverse whole
path and open directory content.
One remark, since I did not mentioned it, I'm using NFSv3, is this
behavior same in NFSv3 and NFSv4?

thanks & regards
Lukasz Tasz
Łukasz Tasz


2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Lukasz Tasz
>> Sent: Thursday, November 29, 2012 4:41 AM
>> To: Adrien Kunysz
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: nfs performance - idea.
>>
>> Any idea on this topic?
>>
>> Can I assume that "touch" could be interface for triggering synchronising
>> client state with server state?
>>
>
> 'ls' is better. All opendir() calls will trigger a revalidation of the directory cache.
>
>
>> many thanks for help!
>> regards
>> Lukasz Tasz
>>
>>
>> 2012/11/14 Adrien Kunysz <adk@acunu.com>:
>> > On Wed, Nov 14, 2012 at 1:38 PM, Łukasz Tasz <lukasz@tasz.eu> wrote:
>> >> Hi all,
>> >>
>> >> I would like to consult some idea with you,
>> >>
>> >> Problem:
>> >> I have two processes which are doing some actions and one of the
>> >> action is done on a shared file system.
>> >> Issue is that this thing could be done only by one process, and for
>> >> this issue, locking mechanism is implemented.
>> >> Problem is that while one process is releasing lock, second one is
>> >> informed that file processing is finished, but unfortunately files
>> >> does not exists in context of second process.
>> >> Two processes are executed on two different hosts. NFS share is
>> >> mounted in a standard way, no special flag.
>> >> Problem I guess is with caches, lookupcache=none solves the problem,
>> >> but also causes others :) - performance.
>> >>
>> >> I know, it not possible to have all things at once - no complains.
>> >> But simple idea is that inside second process after notification that
>> >> files are generated execute touch function on directory which holds
>> >> files, This will cause unnecessary update of modification date, but
>> >> as a side effect I noticed  that also file gets visible immediately
>> >> on client hosts.
>> >>
>> >> That's why my question is if this is expected and reasonable behaviour?
>> >> At the end I'm looking for kind of 'sync' command which will cause
>> >> synchronization of directories content inside client and server
>> >> something like flush() - but in NFS it's more complex.
>> >
>> > Doesn't fsync(2) do what you want? If not, can you explain why?
>> >
>> >> thanks in advance for help,
>> >>
>> >> regards
>> >> Lukasz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
>> body of a message to majordomo@vger.kernel.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html

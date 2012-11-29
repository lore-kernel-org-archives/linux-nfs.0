Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60673 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab2K2JlY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 04:41:24 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so11717342iea.19
        for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2012 01:41:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA4Z2ZQHAvZoUE6h9aqHSZwWF8jvY5QSYai0nXK9gZr6-BN+qA@mail.gmail.com>
References: <CAGRr-NiRkkhoVG4ss5WG7RXXOUWQ5dcOaVAxbQ2yA2c1NbPjKw@mail.gmail.com>
 <CAA4Z2ZQHAvZoUE6h9aqHSZwWF8jvY5QSYai0nXK9gZr6-BN+qA@mail.gmail.com>
From: =?UTF-8?B?xYF1a2FzeiBUYXN6?= <lukasz@tasz.eu>
Date: Thu, 29 Nov 2012 10:40:53 +0100
Message-ID: <CAGRr-NjKsSGoL5P8n8nsfk3eoAY8zZt+h1K6rU19cLitTD78uw@mail.gmail.com>
Subject: Re: nfs performance - idea.
To: Adrien Kunysz <adk@acunu.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any idea on this topic?

Can I assume that "touch" could be interface for triggering
synchronising client state with server state?

many thanks for help!
regards
Lukasz Tasz


2012/11/14 Adrien Kunysz <adk@acunu.com>:
> On Wed, Nov 14, 2012 at 1:38 PM, Łukasz Tasz <lukasz@tasz.eu> wrote:
>> Hi all,
>>
>> I would like to consult some idea with you,
>>
>> Problem:
>> I have two processes which are doing some actions and one of the
>> action is done on a shared file system.
>> Issue is that this thing could be done only by one process, and for
>> this issue, locking mechanism is implemented.
>> Problem is that while one process is releasing lock, second one is
>> informed that file processing is finished, but unfortunately files
>> does not exists in context of second process.
>> Two processes are executed on two different hosts. NFS share is
>> mounted in a standard way, no special flag.
>> Problem I guess is with caches, lookupcache=none solves the problem,
>> but also causes others :) - performance.
>>
>> I know, it not possible to have all things at once - no complains.
>> But simple idea is that inside second process after notification that
>> files are generated execute touch function on directory which holds
>> files,
>> This will cause unnecessary update of modification date, but as a side
>> effect I noticed  that also file gets visible immediately on client
>> hosts.
>>
>> That's why my question is if this is expected and reasonable behaviour?
>> At the end I'm looking for kind of 'sync' command which will cause
>> synchronization of directories content inside client and server
>> something like flush() - but in NFS it's more complex.
>
> Doesn't fsync(2) do what you want? If not, can you explain why?
>
>> thanks in advance for help,
>>
>> regards
>> Lukasz

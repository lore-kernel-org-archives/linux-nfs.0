Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36028 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043Ab2JHQrc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Oct 2012 12:47:32 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so97632iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 08 Oct 2012 09:47:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5072B1E5.9060808@RedHat.com>
References: <CAA7C2qiZhHD7-RHP93LCVOBGCmp4JxyJwRLa0AR8a=oi4fi2Gg@mail.gmail.com>
	<5072B1E5.9060808@RedHat.com>
Date: Mon, 8 Oct 2012 09:47:31 -0700
Message-ID: <CAA7C2qjRPs3pb66s2HDJqEyn0yGfGS_88+yvJNo0fhFQ9M6S3g@mail.gmail.com>
Subject: Re: Problem with rpcbind
From: VDR User <user.vdr@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 8, 2012 at 3:58 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> Per Aníbal Salazar, I'm sending this to the nfs mailing list..
>>
>> ==========
>>
>> Hi. I would like to know who I can talk to about having the rpcbind's
>> timeout value settable on the command line by the user. In many cases
>> the timeout is too long, requiring hackish solutions. It would be
>> best, and makes sense, that the user should be able to set the timeout
>> to something other than the default value if he chooses. If you could
>> direct me to the right person to talk to about it, I'd appreciate it.
>
> What timeout are you referring to? The one given to poll()?

Hi. I guess so but not really sure. I'm talking about the timeout that
happens when rpcbind is waiting for a response. Sounds like poll()
could be it. We have an nfs server on .100 and the response happens
immediately.

$ rpcinfo -t 192.168.1.100 nfs
program 100003 version 2 ready and waiting
program 100003 version 3 ready and waiting
program 100003 version 4 ready and waiting

but there's no server on say .101 so if we run the same command on
that ip, the timeout takes a very long time. It's this timeout that
should be user-definable on the command line in my opinion. Any
thoughts about it?

Cheers

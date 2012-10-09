Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab2JIXhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 19:37:32 -0400
Message-ID: <5074B53A.3030207@RedHat.com>
Date: Tue, 09 Oct 2012 19:37:30 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: VDR User <user.vdr@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Problem with rpcbind
References: <CAA7C2qiZhHD7-RHP93LCVOBGCmp4JxyJwRLa0AR8a=oi4fi2Gg@mail.gmail.com> <5072B1E5.9060808@RedHat.com> <CAA7C2qjRPs3pb66s2HDJqEyn0yGfGS_88+yvJNo0fhFQ9M6S3g@mail.gmail.com>
In-Reply-To: <CAA7C2qjRPs3pb66s2HDJqEyn0yGfGS_88+yvJNo0fhFQ9M6S3g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/12 12:47, VDR User wrote:
> On Mon, Oct 8, 2012 at 3:58 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>> Per Aníbal Salazar, I'm sending this to the nfs mailing list..
>>>
>>> ==========
>>>
>>> Hi. I would like to know who I can talk to about having the rpcbind's
>>> timeout value settable on the command line by the user. In many cases
>>> the timeout is too long, requiring hackish solutions. It would be
>>> best, and makes sense, that the user should be able to set the timeout
>>> to something other than the default value if he chooses. If you could
>>> direct me to the right person to talk to about it, I'd appreciate it.
>>
>> What timeout are you referring to? The one given to poll()?
> 
> Hi. I guess so but not really sure. I'm talking about the timeout that
> happens when rpcbind is waiting for a response. Sounds like poll()
> could be it. We have an nfs server on .100 and the response happens
> immediately.
> 
> $ rpcinfo -t 192.168.1.100 nfs
> program 100003 version 2 ready and waiting
> program 100003 version 3 ready and waiting
> program 100003 version 4 ready and waiting
> 
> but there's no server on say .101 so if we run the same command on
> that ip, the timeout takes a very long time. It's this timeout that
> should be user-definable on the command line in my opinion. Any
> thoughts about it?
Hmm... I'm guess that is the 7min tcp connect time out cause by
the -t option... Try using -u instead of -t... Basically using
UDP instead of TCP... In general I would never recommend that
but in this particular case it might help... 

steved.


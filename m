Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33955 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753AbbFRTYy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 15:24:54 -0400
Received: by ykfl8 with SMTP id l8so74573163ykf.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 12:24:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150617230819.0a11e47a@grimm.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
Date: Thu, 18 Jun 2015 15:24:52 -0400
Message-ID: <CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2015 at 11:08 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Fri, 12 Jun 2015 11:50:38 -0400
> Steven Rostedt <rostedt@goodmis.org> wrote:
>
>> I reverted the following commits:
>>
>> c627d31ba0696cbd829437af2be2f2dee3546b1e
>> 9e2b9f37760e129cee053cc7b6e7288acc2a7134
>> caf4ccd4e88cf2795c927834bc488c8321437586
>>
>> And the issue goes away. That is, I watched the port go from
>> ESTABLISHED to TIME_WAIT, and then gone, and theirs no hidden port.
>>
>> In fact, I watched the port with my portlist.c module, and it
>> disappeared there too when it entered the TIME_WAIT state.
>>

I've scanned those commits again and again, and I'm not seeing how we
could be introducing a socket leak there. The only suspect I can see
would be the NFS swap bugs that Jeff fixed a few weeks ago. Are you
using NFS swap?

> I've been running v4.0.5 with the above commits reverted for 5 days
> now, and there's still no hidden port appearing.
>
> What's the status on this? Should those commits be reverted or is there
> another solution to this bug?
>

I'm trying to reproduce, but I've had no luck yet.

Cheers
  Trond

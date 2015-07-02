Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36078 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbbGBU0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 16:26:21 -0400
MIME-Version: 1.0
In-Reply-To: <20150702164332.GL17109@ZenIV.linux.org.uk>
References: <5593CE37.4070307@samsung.com>
	<20150701184408.GF17109@ZenIV.linux.org.uk>
	<20150702032042.GA32613@ZenIV.linux.org.uk>
	<20150702041046.GG17109@ZenIV.linux.org.uk>
	<CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
	<20150702075932.GI17109@ZenIV.linux.org.uk>
	<CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
	<20150702082529.GJ17109@ZenIV.linux.org.uk>
	<20150702084208.GK17109@ZenIV.linux.org.uk>
	<55952C6D.50805@samsung.com>
	<20150702164332.GL17109@ZenIV.linux.org.uk>
Date: Thu, 2 Jul 2015 23:26:19 +0300
Message-ID: <CAPAsAGy51DQNpnst6W3n2aZGCBMLt5KZ_niieZuM_1pnqoEhDg@mail.gmail.com>
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-07-02 19:43 GMT+03:00 Al Viro <viro@zeniv.linux.org.uk>:
> On Thu, Jul 02, 2015 at 03:19:57PM +0300, Andrey Ryabinin wrote:
>
>> Added:
>> +    if (total > count)
>> +           *(char *)0 = 0
>>
>> and never hit this condition.
>>
>
> OK, so it's definitely a mismatched response.
>
>>         req->tc->tag = tag-1;
>> +       if (WARN_ON(req->status != REQ_STATUS_IDLE))
>> +               pr_err("req->status: %d\n", req->status);
>>         req->status = REQ_STATUS_ALLOC;
>>
>>         return req;
>
>> [  150.259076] 9pnet: req->status: 4
>
> IOW, REQ_STATUS_RCVD.  Hmm...  Stray tag seen by req_done() after we'd already
> freed the tag in question?  That, or it really would have to had wrapped
> around...  Note that req_done() does *not* check anything about the req -
> not even that p9_tag_lookup() hasn't returned NULL, so a server sending you
> any response tagged with number well above anything you'd ever sent will
> reliably oops you.
>
> Frankly, the whole thing needs fuzzing from the server side - start throwing
> crap at the client and see how badly does it get fucked...  Folks, it's
> a network protocol, with userland servers, no less.  You *can't* assume
> them competent and non-malicious...
>
> How much traffic does it take to reproduce that fun, BTW?  IOW, is attempting
> to log the sequence of tag {allocation,freeing}/tag of packet being {sent,
> received} something completely suicidal, or is it more or less feasible?
>

No idea. Usually it takes 1-2 minutes after trinity (100 threads) starts.

>> I didn't get this. c->reqs[row] is always non-NULL as it should be, so this warning
>> will trigger all the time.
>
> ????
>                         row = (tag / P9_ROW_MAXTAG);
>                         c->reqs[row] = kcalloc(P9_ROW_MAXTAG,
>                                         sizeof(struct p9_req_t), GFP_ATOMIC);
>
> and you are seeing c->reqs[row] != NULL *BEFORE* that kcalloc()?  All the time,
> no less?  Just to make sure we are on the same page - the delta against
> mainline I would like tested is this:
>

Ah, I was looking at the second ' row = tag / P9_ROW_MAXTAG;' line
which is after kcalloc().
I'll check tomorrow then.

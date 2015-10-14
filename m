Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35047 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbbJNROo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 13:14:44 -0400
Received: by oixx6 with SMTP id x6so15769488oix.2
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2015 10:14:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyG==2S2-xSsqY-0fHk=Rrk0SsRML9J77ahbQwkp4vgAkg@mail.gmail.com>
References: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
	<CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
	<CAN-5tyHMCMekT0gJE1zNQLO0P5bVgjr_PuQF1BYhNy7n4KBvHg@mail.gmail.com>
	<CAHQdGtQfBZ4yRCkZ0-voFekTEx8fJ1kHCzrmtjr3RHh-dqOuww@mail.gmail.com>
	<CAN-5tyGme1rm+hD0JpOc3co0=_u2hzPwR7eN3AT4_TjVA4NkDA@mail.gmail.com>
	<CAN-5tyFZRU3zCSKU7wNoGzwDF9hn2Vvq6+JL9cWQnuhwoBftyg@mail.gmail.com>
	<CAHQdGtRzyiqjEj8Z2eBjk6ugzG8maK+F2BnO69JsX4ntCOzCcw@mail.gmail.com>
	<CAN-5tyHGp4ihz3pzcmX+xjm5aba8SA3Pfxw-nxNTKv9tFikaGw@mail.gmail.com>
	<CAHQdGtQJm6rFiNgF+SVCx_3SAnzBgHu8mXToWu_uNwJHYCZzqA@mail.gmail.com>
	<m2fv1esla2.fsf@discipline.rit.edu>
	<CAHQdGtS9NKgi0EcS-vQy9sVveGG-id4cKeTBr7dAeTs+93+Cuw@mail.gmail.com>
	<CAN-5tyG==2S2-xSsqY-0fHk=Rrk0SsRML9J77ahbQwkp4vgAkg@mail.gmail.com>
Date: Wed, 14 Oct 2015 13:14:43 -0400
Message-ID: <CAHQdGtQYZoswAKZh3E+yFzTdFL7_RN_JLN7R-8OEosFj87AaLA@mail.gmail.com>
Subject: Re: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Andrew W Elble <aweits@rit.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 10:58 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Tue, Oct 13, 2015 at 3:46 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Tue, Oct 13, 2015 at 1:58 PM, Andrew W Elble <aweits@rit.edu> wrote:
>>>
>>> Trond Myklebust <trond.myklebust@primarydata.com> writes:
>>>
>>> >> > OK. So what are the symptoms? I'm having trouble seeing how a race can
>>> >> > happen, given a correctly coded server.
>>> >>
>>> >> Here's what the server sees:
>>> >> open (foobar) replies back with a delegation
>>> >> various operations including a close()
>>> >> some time goes by...
>>> >> open (foobar) replies back with the same delegation
>>> >
>>> > Why? Olga, we already had this discussion. That sort of server
>>> > behaviour is never going to work without races and is the root cause
>>> > of your problem. We simply won't ever support servers that do this.
>>>
>>> Trond,
>>>
>>>   Specifically, what would the correct behavior be here?
>>
>> The server should honour the open without repeating the delegation.
>>
>> The client already knows about the delegation due to the first open,
>> so there is no value whatsoever in repeating it. In addition, as you
>> see from Olga's example, it causes races with the return of that
>> delegation.
>
> Trond thank you for the explanations. While I haven't hit the last
> case of the race I would still like to bring up that we've seen a case
> where ACCESS is sent and then DELEGRETURN and then delegation stateid
> is used by the IO. Perhaps the commit 5e99b532bb95 helps in that case.
> But if not, then this case of the race can't be handled by the server.

That's a different bug, and is indeed a client issue. It should be
fixed by commit 24311f884189 + 5e99b532bb95. Please let me know if
that is not the case.

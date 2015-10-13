Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35663 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbbJMRyI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 13:54:08 -0400
Received: by iofl186 with SMTP id l186so29630457iof.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 10:54:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQJm6rFiNgF+SVCx_3SAnzBgHu8mXToWu_uNwJHYCZzqA@mail.gmail.com>
References: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
	<CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
	<CAN-5tyHMCMekT0gJE1zNQLO0P5bVgjr_PuQF1BYhNy7n4KBvHg@mail.gmail.com>
	<CAHQdGtQfBZ4yRCkZ0-voFekTEx8fJ1kHCzrmtjr3RHh-dqOuww@mail.gmail.com>
	<CAN-5tyGme1rm+hD0JpOc3co0=_u2hzPwR7eN3AT4_TjVA4NkDA@mail.gmail.com>
	<CAN-5tyFZRU3zCSKU7wNoGzwDF9hn2Vvq6+JL9cWQnuhwoBftyg@mail.gmail.com>
	<CAHQdGtRzyiqjEj8Z2eBjk6ugzG8maK+F2BnO69JsX4ntCOzCcw@mail.gmail.com>
	<CAN-5tyHGp4ihz3pzcmX+xjm5aba8SA3Pfxw-nxNTKv9tFikaGw@mail.gmail.com>
	<CAHQdGtQJm6rFiNgF+SVCx_3SAnzBgHu8mXToWu_uNwJHYCZzqA@mail.gmail.com>
Date: Tue, 13 Oct 2015 13:54:02 -0400
Message-ID: <CAN-5tyFuW_cBcjWghSjxkSuSJ+5vx5HTBs3mHJyzeoMY0vRTcg@mail.gmail.com>
Subject: Re: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 1:28 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Tue, Oct 13, 2015 at 1:23 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Tue, Oct 13, 2015 at 12:56 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>> > On Tue, Oct 13, 2015 at 12:24 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >> On Tue, Oct 13, 2015 at 10:13 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >>> On Tue, Oct 13, 2015 at 9:27 AM, Trond Myklebust
>> >>> <trond.myklebust@primarydata.com> wrote:
>> >>>> On Tue, Oct 13, 2015 at 8:26 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >>>>>
>> >>>>> On Mon, Oct 12, 2015 at 11:47 PM, Trond Myklebust
>> >>>>> <trond.myklebust@primarydata.com> wrote:
>> >>>>> > On Mon, Oct 12, 2015 at 5:55 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >>>>> >> It'll be nice to know when we return delegations synchronously or not.
>> >>>>> >
>> >>>>> > Why? This patch forces us to carry an otherwise completely unnecessary
>> >>>>> > parameter, so at the very minimum we should have a discussion of what
>> >>>>> > the real use cases are.
>> >>>>>
>> >>>>> I used it to diagnose the race of open and delegreturn. If it's kept
>> >>>>
>> >>>> How were you using it?
>> >>>
>> >>>  I added two more traces points in the beginning of delegreturn and in
>> >>> nfs4_do_open before sending the rpc. I can see that a given file
>> >>> handle:
>> >>> -- delegreturn prepare tracepoint is happening,
>> >>> -- then the tracepoint of before sending the open is logged,
>> >>> -- then delegreturn prepare is logged again,
>> >>> -- then tracepoint for nfs4_open_file which is after receiving reply
>> >>> to the open from the server
>> >>> -- then delegreturn_exit tracepoint
>> >>>
>> >>>     kworker/1:0H-14168 [001] ....   576.571636:
>> >>> nfs4_delegreturn_prepare: error=0 (OK) dev=00:2a fhandle=0x84792ca9
>> >>> issync=0
>> >>>
>> >>>           hammer-13955 [000] ....   576.942632: nfs4_open_file_begin:
>> >>> flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2a:0
>> >>> fhandle=0x00000000 name=00:2a:904/000002CB.ham
>> >>>
>> >>>           hammer-13955 [001] ....   577.043084: nfs4_open_file:
>> >>> error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2a:7708
>> >>> fhandle=0x84792ca9 name=00:2a:904/000002CB.ham
>> >>>
>> >>>     kworker/0:1H-431   [000] ....   577.064013:
>> >>> nfs4_delegreturn_prepare: error=0 (OK) dev=00:2a fhandle=0x84792ca9
>> >>> issync=0
>> >>>
>> >>>     kworker/0:1H-431   [000] ....   577.101076: nfs4_delegreturn_exit:
>> >>> error=0 (OK) dev=00:2a fhandle=0x84792ca9
>> >>>
>> >>>     kworker/0:1H-431   [000] ....   577.113021: nfs4_read:
>> >>> error=-10025 (BAD_STATEID) fileid=00:2a:7708 fhandle=0x84792ca9
>> >>> offset=0 count=64
>> >>>
>> >>>
>> >>>>
>> >>>>> that some delegreturns are synchronous and others are not I think the
>> >>>>> information is useful.
>> >>>>
>> >>>> The only difference between synchronous and asynchronous in this case
>> >>>> is whether or not the process that launched the delegreturn actually
>> >>>> waits for it to complete; a signal could easily prevent it from doing
>> >>>> so without interrupting the delegreturn call itself.
>> >>>> IOW: for complete information when debugging races here, you really
>> >>>> need to examine the return value from the wait call.
>> >>>>
>> >>>>> Speaking of there is a race between state manager thread returning
>> >>>>> used delegations and new open. Previously I thought it was evict
>> >>>>> inode...
>> >>>>
>> >>>> Is this with commit 5e99b532bb95 ("nfs4: reset states to use
>> >>>> open_stateid when returning delegation voluntarily") applied?
>> >>>
>> >>> No I have not. I will try that. Thanks.
>> >>
>> >> This patch does not help. The race is still present.
>> >
>> > OK. So what are the symptoms? I'm having trouble seeing how a race can
>> > happen, given a correctly coded server.
>>
>> Here's what the server sees:
>> open (foobar) replies back with a delegation
>> various operations including a close()
>> some time goes by...
>> open (foobar) replies back with the same delegation
>
> Why? Olga, we already had this discussion. That sort of server
> behaviour is never going to work without races and is the root cause
> of your problem. We simply won't ever support servers that do this.

Given that there is nothing in the spec about this situation, I think
it's not clear that server is acting incorrectly.

Do you think it is not possible to fix the client such that
open/delegreturn race is happening? Isn't VFS layer achieving the same
thing by synchronizing their evict inode code with the new opens?


>
>> delegreturn
>> read (foobar) using delegation

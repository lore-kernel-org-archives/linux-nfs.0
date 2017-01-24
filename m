Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33970 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750883AbdAXWd2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 17:33:28 -0500
Received: by mail-io0-f177.google.com with SMTP id l66so358436ioi.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 14:33:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1485292865.12087.4.camel@primarydata.com>
References: <CAN-5tyF+Uth87mnmWC2UaRU134whqNG8gEyNHBR_hOu9OYSZuw@mail.gmail.com>
 <35619FC0-AD46-4BBA-9F5B-9C89364BAF82@primarydata.com> <CAN-5tyHCUu_gpdiEcVZm-12RdgHtPtDgjbg-ScU9vZ7Tod5qAw@mail.gmail.com>
 <3EA4DDB3-6C9F-42E2-96BD-FF1AFD99ED09@primarydata.com> <CAN-5tyEBtCUL0QgmHU8=u9UJLJdOxDaq=Ta8eTM-hjde1hu9ZA@mail.gmail.com>
 <52D13840-C715-4989-A8D8-DAD2F2EFE99A@primarydata.com> <CAN-5tyFO8wR-Z1nZmBCVSTfvGLGH8xa2yojvsBRyvY4jrwM4Dg@mail.gmail.com>
 <1485292292.12087.2.camel@primarydata.com> <1485292865.12087.4.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 24 Jan 2017 17:33:27 -0500
Message-ID: <CAN-5tyH=65eKtwb7bjqv_-MBK-dmPF99uvp=X3QoTwnQJfrv=A@mail.gmail.com>
Subject: Re: handling error on RECLAIM_COMPLETE
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2017 at 4:21 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Tue, 2017-01-24 at 16:11 -0500, Trond Myklebust wrote:
>> On Tue, 2017-01-24 at 15:48 -0500, Olga Kornievskaia wrote:
>> > On Tue, Jan 24, 2017 at 3:35 PM, Trond Myklebust
>> > <trondmy@primarydata.com> wrote:
>> > >
>> > > > On Jan 24, 2017, at 14:50, Olga Kornievskaia <aglo@umich.edu>
>> > > > wrote:
>> > > >
>> > > > On Tue, Jan 24, 2017 at 2:44 PM, Trond Myklebust
>> > > > <trondmy@primarydata.com> wrote:
>> > > > >
>> > > > > > On Jan 24, 2017, at 14:40, Olga Kornievskaia <aglo@umich.ed
>> > > > > > u>
>> > > > > > wrote:
>> > > > > >
>> > > > > > On Tue, Jan 24, 2017 at 2:12 PM, Trond Myklebust
>> > > > > > <trondmy@primarydata.com> wrote:
>> > > > > > >
>> > > > > > > > On Jan 24, 2017, at 14:06, Olga Kornievskaia <aglo@umic
>> > > > > > > > h.
>> > > > > > > > edu> wrote:
>> > > > > > > >
>> > > > > > > > Hi Trond,
>> > > > > > > >
>> > > > > > > > Is there a reason that nfs4_proc_reclaim_complete()
>> > > > > > > > isn't  wrapped
>> > > > > > > > with a do while() to handle errors?
>> > > > > > >
>> > > > > > > What do we not already handle correctly in
>> > > > > > > nfs4_reclaim_complete_done()?
>> > > > > >
>> > > > > > Could this be because when an error occurs rpc_done isn't
>> > > > > > called
>> > > > > > (rpc_release is called)? What I see is that if
>> > > > > > RECLAIM_COMPLETE gets
>> > > > > > an error (BAD_SESSION) the client just ignores it.
>> > > > > >
>> > > > >
>> > > > > That=E2=80=99s correct. Why do we need to handle BAD_SESSION the=
re?
>> > > > > We=E2=80=99re done with state recovery, so if the server reboote=
d, we
>> > > > > can catch that later.
>> > > >
>> > > > (1) don't we want to handle session errors as soon as possible?
>> > > > (2) I ran into a problem (not sure yet if reproducible) where I
>> > > > had a
>> > > > client stuck in an infinite loop of RECLAIM_COMPLETE being sent
>> > > > with
>> > > > reply of BAD_SESSION.
>> > > >
>> > > > yes I don't know why the client is looping but it made me look
>> > > > into
>> > > > the fact that we are not handling session errors on reclaim
>> > > > complete
>> > > > which I simulated by having the server return BAD_SESSION to
>> > > > RECLAIM_COMPLETE and I see that client simply ignores it.
>> > >
>> > > It doesn=E2=80=99t ignore it:
>> > >
>> > > static int nfs41_reclaim_complete_handle_errors(struct rpc_task
>> > > *task, struct nfs_client *clp)
>> > > {
>> > >         switch(task->tk_status) {
>> > >         case 0:
>> > >         case -NFS4ERR_COMPLETE_ALREADY:
>> > >         case -NFS4ERR_WRONG_CRED: /* What to do here? */
>> > >                 break;
>> > >         case -NFS4ERR_DELAY:
>> > >                 rpc_delay(task, NFS4_POLL_RETRY_MAX);
>> > >                 /* fall through */
>> > >         case -NFS4ERR_RETRY_UNCACHED_REP:
>> > >                 return -EAGAIN;
>> > >         default:
>> > >                 nfs4_schedule_lease_recovery(clp);
>> > >         }
>> > >         return 0;
>> > > }
>> > >
>> > > IOW: what the code does is schedule another round of lease
>> > > recovery.
>> >
>> > We already agreed that this doesn't get called because
>> > rpc_call_done
>> > isn't called on the error.
>>
>> What am I missing? Why wouldn't it get called?
>
> Sorry. I see I caused that confusion. When I said "that is correct", I
> was referring to the fact that the client ignores the error. All it
> does in the case of those errors is to schedule recovery and then exit.
>
> The client will always call rpc_call_done() provided that the RPC call
> was initialised successfully.

Ok. Thanks for clarifying. So something is going on with the
BAD_SESSION error loop but I just don't know what.

I have encountered either SEQUENCE getting into an infinite loop of
getting BAD_SESSION and then once I've seen this RECLAIM_COMPLETE
getting into a loop. I'll keep looking...

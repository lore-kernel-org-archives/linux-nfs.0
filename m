Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:38444 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXTuD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:50:03 -0500
Received: by mail-it0-f44.google.com with SMTP id c7so97583647itd.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 11:50:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3EA4DDB3-6C9F-42E2-96BD-FF1AFD99ED09@primarydata.com>
References: <CAN-5tyF+Uth87mnmWC2UaRU134whqNG8gEyNHBR_hOu9OYSZuw@mail.gmail.com>
 <35619FC0-AD46-4BBA-9F5B-9C89364BAF82@primarydata.com> <CAN-5tyHCUu_gpdiEcVZm-12RdgHtPtDgjbg-ScU9vZ7Tod5qAw@mail.gmail.com>
 <3EA4DDB3-6C9F-42E2-96BD-FF1AFD99ED09@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 24 Jan 2017 14:50:02 -0500
Message-ID: <CAN-5tyEBtCUL0QgmHU8=u9UJLJdOxDaq=Ta8eTM-hjde1hu9ZA@mail.gmail.com>
Subject: Re: handling error on RECLAIM_COMPLETE
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2017 at 2:44 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Jan 24, 2017, at 14:40, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Tue, Jan 24, 2017 at 2:12 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>>
>>>> On Jan 24, 2017, at 14:06, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> Hi Trond,
>>>>
>>>> Is there a reason that nfs4_proc_reclaim_complete() isn't  wrapped
>>>> with a do while() to handle errors?
>>>
>>> What do we not already handle correctly in nfs4_reclaim_complete_done()=
?
>>
>> Could this be because when an error occurs rpc_done isn't called
>> (rpc_release is called)? What I see is that if RECLAIM_COMPLETE gets
>> an error (BAD_SESSION) the client just ignores it.
>>
>
> That=E2=80=99s correct. Why do we need to handle BAD_SESSION there? We=E2=
=80=99re done with state recovery, so if the server rebooted, we can catch =
that later.

(1) don't we want to handle session errors as soon as possible?
(2) I ran into a problem (not sure yet if reproducible) where I had a
client stuck in an infinite loop of RECLAIM_COMPLETE being sent with
reply of BAD_SESSION.

yes I don't know why the client is looping but it made me look into
the fact that we are not handling session errors on reclaim complete
which I simulated by having the server return BAD_SESSION to
RECLAIM_COMPLETE and I see that client simply ignores it.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:56213 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab2JHUY6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Oct 2012 16:24:58 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so2537006lag.19
        for <linux-nfs@vger.kernel.org>; Mon, 08 Oct 2012 13:24:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90900EFF1@SACEXCMBX04-PRD.hq.netapp.com>
References: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
	<1349718630-26008-2-git-send-email-Trond.Myklebust@netapp.com>
	<1349718630-26008-3-git-send-email-Trond.Myklebust@netapp.com>
	<1349718630-26008-4-git-send-email-Trond.Myklebust@netapp.com>
	<CAHVgHyV7aW8TArsu0xi0Nz6AhO98bO2qVzAvY9XZYx7hQZcx4w@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90900EFF1@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 8 Oct 2012 16:24:56 -0400
Message-ID: <CAHVgHyUrm_nprthmLE4NjsyTBNYS-HjiKwFOi7DLjiOTyPJinw@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSv4.1: pNFS has no business touching the slot table
 wait queue...
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 8, 2012 at 4:04 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2012-10-08 at 15:59 -0400, Andy Adamson wrote:
>> On Mon, Oct 8, 2012 at 1:50 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > Aside from it being a layering violation, there is no point in doing so:
>> > - If slots are available, then the waitqueue will be empty.
>> > - If no slots are available, then the wake up just causes waitqueue churn
>>
>> We call rpc_wake_up so that I/O waiting on the DS session, all of
>> which needs to be re-directed to the MDS (not via the state recovery
>> machinery), will by-pass the RPC machine "try each task one at a time
>> and redirect on failure" which includes the 60 second TCP timeout on
>> DS connection failures.
>>
>> So, it doesn't just cause waitqueue churn, it significantly reduces
>> the time it takes to recover to the MDS.
>>
>
> All it does is a wake up... That will happen _ANYWAY_ as soon as a slot
> is made available.

That is true. But why wait? Especially when all tasks are I/O, and if
the application happens to be doing a heavy I/O workload, there can be
hundreds of tasks on that wait queue.

We don't care if any DS slots are available. We have given up and re
redirecting these tasks to the MDS session. The sooner, the better.

I'll re-run some tests and demonstrate the time difference
with/without the rpc_wake_up.

-->Andy

>
> So yes, it is pure churn...
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

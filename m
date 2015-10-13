Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36664 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270AbbJMN1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 09:27:16 -0400
Received: by oihr205 with SMTP id r205so9295343oih.3
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 06:27:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHMCMekT0gJE1zNQLO0P5bVgjr_PuQF1BYhNy7n4KBvHg@mail.gmail.com>
References: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
	<CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
	<CAN-5tyHMCMekT0gJE1zNQLO0P5bVgjr_PuQF1BYhNy7n4KBvHg@mail.gmail.com>
Date: Tue, 13 Oct 2015 09:27:15 -0400
Message-ID: <CAHQdGtQfBZ4yRCkZ0-voFekTEx8fJ1kHCzrmtjr3RHh-dqOuww@mail.gmail.com>
Subject: Re: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 8:26 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>
> On Mon, Oct 12, 2015 at 11:47 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > On Mon, Oct 12, 2015 at 5:55 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >> It'll be nice to know when we return delegations synchronously or not.
> >
> > Why? This patch forces us to carry an otherwise completely unnecessary
> > parameter, so at the very minimum we should have a discussion of what
> > the real use cases are.
>
> I used it to diagnose the race of open and delegreturn. If it's kept

How were you using it?

> that some delegreturns are synchronous and others are not I think the
> information is useful.

The only difference between synchronous and asynchronous in this case
is whether or not the process that launched the delegreturn actually
waits for it to complete; a signal could easily prevent it from doing
so without interrupting the delegreturn call itself.
IOW: for complete information when debugging races here, you really
need to examine the return value from the wait call.

> Speaking of there is a race between state manager thread returning
> used delegations and new open. Previously I thought it was evict
> inode...

Is this with commit 5e99b532bb95 ("nfs4: reset states to use
open_stateid when returning delegation voluntarily") applied?

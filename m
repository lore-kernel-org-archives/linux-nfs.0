Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33069 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbJMM0o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 08:26:44 -0400
Received: by iodv82 with SMTP id v82so18697057iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 05:26:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
References: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
	<CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
Date: Tue, 13 Oct 2015 08:26:43 -0400
Message-ID: <CAN-5tyHMCMekT0gJE1zNQLO0P5bVgjr_PuQF1BYhNy7n4KBvHg@mail.gmail.com>
Subject: Re: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 11:47 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Mon, Oct 12, 2015 at 5:55 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> It'll be nice to know when we return delegations synchronously or not.
>
> Why? This patch forces us to carry an otherwise completely unnecessary
> parameter, so at the very minimum we should have a discussion of what
> the real use cases are.

I used it to diagnose the race of open and delegreturn. If it's kept
that some delegreturns are synchronous and others are not I think the
information is useful.

Speaking of there is a race between state manager thread returning
used delegations and new open. Previously I thought it was evict
inode...

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

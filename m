Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f45.google.com ([74.125.83.45]:61053 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaEVJFM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 05:05:12 -0400
Date: Thu, 22 May 2014 11:05:02 +0200
From: Ingo Molnar <mingo@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com,
        Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>,
        Steve French <sfrench@samba.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140522090502.GB30094@gmail.com>
References: <20140501123738.3e64b2d2@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140501123738.3e64b2d2@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* NeilBrown <neilb@suse.de> wrote:

> [[ get_maintainer.pl suggested 61 email address for this patch.
>    I've trimmed that list somewhat.  Hope I didn't miss anyone
>    important...
>    I'm hoping it will go in through the scheduler tree, but would
>    particularly like an Acked-by for the fscache parts.  Other acks
>    welcome.
> ]]
> 
> The current "wait_on_bit" interface requires an 'action' function
> to be provided which does the actual waiting.
> There are over 20 such functions, many of them identical.
> Most cases can be satisfied by one of just two functions, one
> which uses io_schedule() and one which just uses schedule().
> 
> So:
>  Rename wait_on_bit and        wait_on_bit_lock to
>         wait_on_bit_action and wait_on_bit_lock_action
>  to make it explicit that they need an action function.
> 
>  Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
>  which are *not* given an action function but implicitly use
>  a standard one.
>  The decision to error-out if a signal is pending is now made
>  based on the 'mode' argument rather than being encoded in the action
>  function.

this patch fails to build on x86-32 allyesconfigs.

Could we keep the old names for a while, and remove them in the next 
cycle or so?

Thanks,

	Ingo

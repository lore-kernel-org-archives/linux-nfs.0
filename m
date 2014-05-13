Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbaEMQJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 May 2014 12:09:29 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20140501123738.3e64b2d2@notabene.brown>
References: <20140501123738.3e64b2d2@notabene.brown>
To: NeilBrown <neilb@suse.de>
Cc: dhowells@redhat.com, Peter Zijlstra <peterz@infradead.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com,
        Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>,
        Steve French <sfrench@samba.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action functions.
Date: Tue, 13 May 2014 17:08:46 +0100
Message-ID: <30874.1399997326@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown <neilb@suse.de> wrote:

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

Yay!  About time!  This is something I've wanted to do for ages, but never
quite got around to.

Acked-by: David Howells <dhowells@redhat.com>

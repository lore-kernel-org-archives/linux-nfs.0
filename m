Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaEMQGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 May 2014 12:06:53 -0400
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
From: David Howells <dhowells@redhat.com>
Date: Tue, 13 May 2014 17:06:10 +0100
Message-ID: <30769.1399997170@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown <neilb@suse.de> wrote:

> The wait_on_bit() call in __fscache_wait_on_invalidate() was ambiguous
> as it specified TASK_UNINTERRUPTIBLE but used
> fscache_wait_bit_interruptible as an action function.
> As any error return is never checked I assumed that 'uninterruptible'
> was correct.

Bug.  It should be uninterruptible in both places.

David

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:42754 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbaIYFBI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 01:01:08 -0400
Date: Thu, 25 Sep 2014 07:01:03 +0200
From: Ingo Molnar <mingo@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>,
        linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/5 - resend] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140925050103.GB20431@gmail.com>
References: <20140924012422.4838.29188.stgit@notabene.brown>
 <20140924012832.4838.59410.stgit@notabene.brown>
 <20140924070418.GA990@gmail.com>
 <20140925135519.3ae1fa60@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140925135519.3ae1fa60@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* NeilBrown <neilb@suse.de> wrote:

> 
> In commit c1221321b7c25b53204447cff9949a6d5a7ddddc
>    sched: Allow wait_on_bit_action() functions to support a timeout
> 
> I suggested that a "wait_on_bit_timeout()" interface would not meet my
> need.  This isn't true - I was just over-engineering.
> 
> Including a 'private' field in wait_bit_key instead of a focused
> "timeout" field was just premature generalization.  If some other
> use is ever found, it can be generalized or added later.
> 
> So this patch renames "private" to "timeout" with a meaning "stop
> waiting when "jiffies" reaches or passes "timeout",
> and adds two of the many possible wait..bit..timeout() interfaces:
> 
> wait_on_page_bit_killable_timeout(), which is the one I want to use,
> and out_of_line_wait_on_bit_timeout() which is a reasonably general
> example.  Others can be added as needed.
> 
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> ---
> This time with EXPORT_SYMBOL_GPL.

Looks good to me, thanks!

Acked-by: Ingo Molnar <mingo@kernel.org>

	Ingo

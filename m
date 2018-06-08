Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44894 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751280AbeFHQQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Jun 2018 12:16:05 -0400
Date: Fri, 8 Jun 2018 12:16:05 -0400
To: Chris Takemura <ctakemura@google.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd threads hanging in nfsd4_cstate_assign_replay?
Message-ID: <20180608161605.GB12719@fieldses.org>
References: <CAJf8aWTT-UMvTm6uKumm9kVBF+7mcfzoL51GM8kJJ=3TgY_HBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJf8aWTT-UMvTm6uKumm9kVBF+7mcfzoL51GM8kJJ=3TgY_HBg@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 04, 2018 at 01:22:05PM -0700, Chris Takemura wrote:
> Hi linux-nfs,
> 
> I've got an NFS server that's behaving a little oddly -- it loses
> threads to disk sleep at the rate of about 1 every 5 minutes.  Threads
> stuck in this state all have the same stack:
> 
> [<ffffffffc069e4ce>] nfsd4_cstate_assign_replay.part.78+0x1e/0x30 [nfsd]
> [<ffffffffc06a4ecc>] nfs4_preprocess_seqid_op+0xfc/0x190 [nfsd]
> [<ffffffffc06a5bb6>] nfsd4_close+0x66/0x2c0 [nfsd]
> [<ffffffffc06934fe>] nfsd4_proc_compound+0x3be/0x720 [nfsd]
> [<ffffffffc067fec6>] nfsd_dispatch+0xd6/0x270 [nfsd]
> [<ffffffffc04eef16>] svc_process_common+0x456/0x730 [sunrpc]
> [<ffffffffc04ef2f5>] svc_process+0x105/0x1c0 [sunrpc]
> [<ffffffffc067f8f0>] nfsd+0xf0/0x160 [nfsd]
> [<ffffffffb109f158>] kthread+0xd8/0xf0
> [<ffffffffb181b6f5>] ret_from_fork+0x55/0x80
> [<ffffffffffffffff>] 0xffffffffffffffff

Looks like they're trying to so->so_replay.rp_mutex but are getting
stuck on it indefinitely.

That mutex is supposed to be released by nfsd4_cstate_clear_replay().

So it's a matter of tracing through the callers to figure out if there's
a codepath where one's called but not the other.

There's no way out of the main op-processing loop in
nfsd4_proc_compound() without calling nfsd4_cstate_clear_replay() at the
end.

I don't see it immediately.  Most likely might be
nfsd4_cstate_assign_replay getting called twice somehow.  We could
stick a WARN_ON_ONCE(cstate->replay_ownere) at the start of that
function.

Might also be interesting to know whether the problem's still
reproduceable on a more recent kernel.

--b.

> 
> This is on ubuntu, with kernel version 4.4.0-119-generic
> #143~14.04.1-Ubuntu.  As you can tell from the backtrace, it's serving
> NFS4.
> 
> I've been increasing the thread count to compensate for the hung
> threads -- note that the total number of threads doesn't affect the
> rate of hangs, which is stubbornly constant.
> 
> Do you have any idea what could be causing this, and how I can stop
> it, preferably without interrupting service?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:51834 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbaIPWE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Sep 2014 18:04:56 -0400
Received: by mail-vc0-f180.google.com with SMTP id hq11so541627vcb.11
        for <linux-nfs@vger.kernel.org>; Tue, 16 Sep 2014 15:04:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140916053135.22257.46476.stgit@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053135.22257.46476.stgit@notabene.brown>
Date: Tue, 16 Sep 2014 18:04:55 -0400
Message-ID: <CAHQdGtQbFtLFEpzgqoMoLiG7-Y0FdFiZdpS4dgkT7hsCnqMiPA@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFS/SUNRPC: Remove other deadlock-avoidance
 mechanisms in nfs_release_page()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On Tue, Sep 16, 2014 at 1:31 AM, NeilBrown <neilb@suse.de> wrote:
> Now that nfs_release_page() doesn't block indefinitely, other deadlock
> avoidance mechanisms aren't needed.
>  - it doesn't hurt for kswapd to block occasionally.  If it doesn't
>    want to block it would clear __GFP_WAIT.  The current_is_kswapd()
>    was only added to avoid deadlocks and we have a new approach for
>    that.
>  - memory allocation in the SUNRPC layer can very rarely try to
>    ->releasepage() a page it is trying to handle.  The deadlock
>    is removed as nfs_release_page() doesn't block indefinitely.
>
> So we don't need to set PF_FSTRANS for sunrpc network operations any
> more.

Jeff Layton and I had a little discussion about this earlier today.
The issue that Jeff raised was that these 1 second waits, although
they will eventually complete, can nevertheless have a cumulative
large effect if, say, the reason why we're not making progress is that
we're being called as part of a socket reconnect attempt in
xs_tcp_setup_socket().

In that case, any attempts to call nfs_release_page() on pages that
need to use that socket, will result in a 1 second wait, and no
progress in satisfying the allocation attempt.

Our conclusion was that we still need the PF_FSTRANS in order to deal
with that case, where we need to actually circumvent the new wait in
order to guarantee progress on the task of allocating and connecting
the new socket.

Comments?

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

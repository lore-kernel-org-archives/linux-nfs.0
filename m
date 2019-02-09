Return-Path: <SRS0=azzX=QQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5224C282C4
	for <linux-nfs@archiver.kernel.org>; Sat,  9 Feb 2019 12:44:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9CC702084D
	for <linux-nfs@archiver.kernel.org>; Sat,  9 Feb 2019 12:44:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727068AbfBIMoB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 9 Feb 2019 07:44:01 -0500
Received: from mail-qk1-f194.google.com ([209.85.222.194]:45186 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726741AbfBIMn6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Feb 2019 07:43:58 -0500
Received: by mail-qk1-f194.google.com with SMTP id y78so3745385qka.12
        for <linux-nfs@vger.kernel.org>; Sat, 09 Feb 2019 04:43:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=MwBSvILaWD7Vm3fNl1FktF2rtQrZGKuMb4+yUb0mSp8=;
        b=Jun981NmpuT2VQuVWm9nshE1HKe6aZd9L/sRaps+ZWDbSGaslJlMOYLeGPb0zcxB1q
         Sr6hOOMluo3UXKiR4D5yJ9SXCYYSKPuveC+HN2Q2LnLGLDdcEdJPGq0arZNJrLPwJWnH
         GUc87Wr5Y1jk9SR0aPaiJVu0H/y5IOuFRs5FJqZjyKn/Yylqvc8Y+S0WeHbyGd+/Tnrb
         nWdWvYJHN8J8iJGN+mZMY0kWaEUBBFpD26qsz2zDe14dsOlWaVWYgs9r1ZW8I99En1yB
         JUgndn8otIXaPy4Rw1NUpfI4kPtkSreXGUXA1q3UYSDFPwZWPfSzT/EN9MatgJokIPK6
         wzWg==
X-Gm-Message-State: AHQUAuZO2wKH7pRqE/6cDdEFW6OZbiYgK+13IxATwmrjMd/Mo0yc3mBL
        qi/fvab+ZYFWUHp++XuBDkeQ1O4s2/U=
X-Google-Smtp-Source: AHgI3IY9eeYu+bCbWVt7mgxXs/GjMhd/VbUEeUHbDKb00UI0BUFsWs3eKdyEEvEFZT2MMBssumbZhA==
X-Received: by 2002:a37:7847:: with SMTP id t68mr17724901qkc.254.1549716237744;
        Sat, 09 Feb 2019 04:43:57 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-150.dyn6.twc.com. [2606:a000:1100:db::150])
        by smtp.gmail.com with ESMTPSA id u4sm3622453qkk.51.2019.02.09.04.43.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 04:43:56 -0800 (PST)
Message-ID: <bbc264481c2368f1e7a386cafb0cd5fba6af7ecf.camel@redhat.com>
Subject: Re: [PATCH 0/7] Eliminate delegation self-conflicts
From:   Jeff Layton <jlayton@redhat.com>
To:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>
Date:   Sat, 09 Feb 2019 07:43:54 -0500
In-Reply-To: <1549656647-25115-1-git-send-email-bfields@redhat.com>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-08 at 15:10 -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> These patches allow NFSv4 clients holding delegations to keep them when
> the operation that would break a delegation comes from the same client.
> 
> To do that, we somehow need to pass the identity of the
> delegation-breaker down through the VFS.
> 
> This series uses the tgid, a solution suggested by Trond.  To do that we
> need nfsd tasks to share the same tgid.  I do that by extending the
> kthread code slightly to allow knfsd to run the kthreadd main loop in a
> task of its own, and spawn its server threads off of that task.
> 
> Part of Trond's thinking was that this would work for userspace too.
> Delegations are currently only available to knfsd, but Ganesha and Samba
> may eventually be interested in a userspace interface (probably a minor
> variation on the fcntl F_{GET,SET}LEASE interface).  A threaded
> userspace server would first resolve conflicts between its own clients,
> and then call into the kernel to break any leases acquired by other
> processes.  That may require some careful locking of the server's own
> data structures, but it should work.
> 
> Previously I considered instead adding a new field somewhere in the
> struct task.  That might require a new system call to expose to user
> space.  Or we might be able to put this in a keyring, if David Howells
> thought that would work.
> 
> Before that I tried passing the identity of the breaker explicitly, but
> that looks like it would require passing the new argument around to huge
> swaths of the VFS.
> 
> I'm testing this with some a locally modified pynfs; I'll fix that up
> and push it out at some point, but pynfs has a number of bugs in this
> area.
> 
> I wasn't sure who to ask about the kthread.c changes, so I'm cc'ing a
> random assortment of developers in recent changelogs, hope that's OK.
> 
> --b.
> 
> J. Bruce Fields (7):
>   kthreads: minor kthreadd refactoring
>   kthreads: Simplify tsk_fork_get_node
>   kthreads: allow multiple kthreadd's
>   kthreads: allow cloning threads with different flags
>   rpc: separate out body of svc_start_kthreads
>   rpc: move rpc server threads into their own thread group
>   nfsd: ignore delegation self-conflicts
> 
>  fs/locks.c                 |  39 +++++++++++
>  fs/nfsd/nfs4state.c        |  61 ++++++++++++++++
>  fs/nfsd/state.h            |   2 +
>  fs/nfsd/vfs.c              |  32 +++++++--
>  include/linux/fs.h         |   2 +
>  include/linux/kthread.h    |  21 +++++-
>  include/linux/sunrpc/svc.h |   1 +
>  init/init_task.c           |   3 +
>  init/main.c                |   4 +-
>  kernel/fork.c              |   4 ++
>  kernel/kthread.c           | 140 +++++++++++++++++++++++++++----------
>  net/sunrpc/svc.c           |  83 ++++++++++++++--------
>  12 files changed, 317 insertions(+), 75 deletions(-)
> 

Nice work! I like the basic idea, the changes seem to be well-organized, 
and the tgid semantics are clear and make sense.

Would this preclude us from moving to a workqueue-based model for knfsd
later? It's likely to still be worth it, but it'd be good to understand
the potential drawbacks.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>


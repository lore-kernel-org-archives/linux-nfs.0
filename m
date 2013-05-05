Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f45.google.com ([74.125.83.45]:41334 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab3EEJXX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 May 2013 05:23:23 -0400
Date: Sun, 5 May 2013 11:23:18 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130505092318.GD22239@gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367615050-3894-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Colin Cross <ccross@android.com> wrote:

> NFS calls the freezable helpers with locks held, which is unsafe
> and caused lockdep warnings when 6aa9707 "lockdep: check that no
> locks held at freeze time" was applied (reverted in dbf520a).
> Add new *_unsafe versions of the helpers that will not run the
> lockdep test when 6aa9707 is reapplied, and call them from NFS.
> 
> Signed-off-by: Colin Cross <ccross@android.com>
> ---
>  fs/nfs/inode.c          |  2 +-
>  fs/nfs/nfs3proc.c       |  2 +-
>  fs/nfs/nfs4proc.c       |  4 ++--
>  include/linux/freezer.h | 42 +++++++++++++++++++++++++++++++++++++++++-
>  net/sunrpc/sched.c      |  2 +-
>  5 files changed, 46 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 1f94167..53cbee5 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -79,7 +79,7 @@ int nfs_wait_bit_killable(void *word)
>  {
>  	if (fatal_signal_pending(current))
>  		return -ERESTARTSYS;
> -	freezable_schedule();
> +	freezable_schedule_unsafe();

I'd suggest naming such variants _unkillable() instead of _unsafe().

There's nothing inherently 'unsafe' about it: the user asked for a hard 
NFS mount and is getting it: with the side effect that it exposes the 
machine to network delays in a 'hard' way as well. Which means suspend may 
block indefinitely as well on network failure.

So it's two conflicting user requirements: 'hard NFS mount' and 'suspend 
now'. We pick the lesser evil, the requirement that is considered higher 
prio: the hard NFS mount in this case.

Thanks,

	Ingo

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f66.google.com ([209.85.216.66]:52342 "EHLO
	mail-qa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbaFVA74 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jun 2014 20:59:56 -0400
Received: by mail-qa0-f66.google.com with SMTP id m5so1549736qaj.1
        for <linux-nfs@vger.kernel.org>; Sat, 21 Jun 2014 17:59:56 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 21 Jun 2014 20:59:54 -0400
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] nfs4: file locking fixes and cleanups
Message-ID: <20140621205954.6ff89007@tlielax.poochiereds.net>
In-Reply-To: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  1 May 2014 06:28:44 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

> Hi Trond,
> This set is basically unchanged from the last one, aside from a bit
> more cleanup of unneeded arguments in patch #1.
> 
> I know that you basically NAKed this set earlier this week. The issue
> you saw was that the generic locking codepaths never set the fl_owner
> value for flock locks. That's true, but nfs_flock does set this for any
> file_lock request that comes through it, so patch #1 is safe to apply
> now if you see no other issue with it.
> 
> I have a patch queued for v3.16 that makes the generic flock codepaths
> set the fl_owner, but that's just cleanup and won't really affect how
> this works.
> 
> The main problem that I think we need to fix soon though is the one that
> patch #2 fixes. An unprivileged user can trigger that BUG() and if
> panic_on_oops is set, then that's an unprivileged DoS at least.
> 
> Jeff Layton (3):
>   nfs4: treat lock owners as opaque values
>   nfs4: queue free_lock_state job submission to nfsiod
>   nfs4: turn free_lock_state into a void return operation
> 
>  fs/nfs/nfs4_fs.h   | 26 +++++++-------------
>  fs/nfs/nfs4proc.c  | 14 +++++------
>  fs/nfs/nfs4state.c | 69 +++++++++++++++++++++---------------------------------
>  3 files changed, 42 insertions(+), 67 deletions(-)
> 

Hi Trond,

The patch that moves the setting of fl_owner for flock locks into the
generic locking code was merged for v3.16. Are you willing to rescind
your earlier NACK now that that's done?

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>

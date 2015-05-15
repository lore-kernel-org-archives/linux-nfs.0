Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38272 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934744AbbEOPwJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2015 11:52:09 -0400
Received: by igcau1 with SMTP id au1so31590078igc.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 May 2015 08:52:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com>
Date: Fri, 15 May 2015 11:52:08 -0400
Message-ID: <CAN-5tyHKh0kFDqmq_9ZyTmzmMx33f2wixrWBpi5hx=YXF0kihg@mail.gmail.com>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's another version:

Problem: When an operation like WRITE receives a BAD_STATEID, even though
recovery code clears the RECLAIM_NOGRACE recovery flag before recovering
the open state, because of clearing delegation state for the associated
inode, nfs_inode_find_state_and_recover() gets called and it marks the
same state with RECLAIM_NOGRACE flag again. As a results, when we restart
looking over the open states, we end up in the infinite loop instead of
breaking out in the next test of state flags.

Solution: unset the RECLAIM_NOGRACE set because of
calling of nfs_inode_find_state_and_recover() after returning from calling
recover_open() function.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2782cfc..e99e1f0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1482,6 +1482,8 @@ restart:
                                        spin_unlock(&state->state_lock);
                                }
                                nfs4_put_open_state(state);
+                               test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE,
+                                       &state->flags);
                                spin_lock(&sp->so_lock);
                                goto restart;
                        }
-- 

On Thu, May 7, 2015 at 1:04 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi folks,
>
> Problem:
> The upstream nfs4.0 client has problem where it will go into an
> infinite loop of re-sending an OPEN when it's trying to recover from
> receiving a BAD_STATEID error on an IO operation such READ or WRITE.
>
> How to easily reproduce (by using fault injection):
> 1. Do nfs4.0 mount to a server.
> 2. Open a file such that the server gives you a write delegation.
> 3. Do a write. Have a server return a BAD_STATEID. One way to do so is
> by using a python proxy, nfs4proxy, and inject BAD_STATEID error on
> WRITE.
> 4. And off it goes with the loop.
>
> Here’s why….
>
> IO op like WRITE receives a BAD_STATEID.
> 1. for this error, in async handle error we  call
> nfs4_schedule_stateid_recover()
> 2. that in turn will call nfs4_state_mark_reclaim_nograce() that will
> set a RECLAIM_NOGRACE in the state flags.
> 3. state manager thread will run and call nfs4_do_reclaim() to recover.
> 4. that will call nfs4_reclaim_open_state()
>
> in that function:
>
> restart:
> for open states in state
> test if RECLAIM_NOGRACE is set in state flags, if so clear it (it’s
> set and we’ll clear it)
> check open_stateid (checks if RECOVERY_FAILED is not set) (it’s not)
> checks if we have state
> calls ops->recover_open()
>
> for nfs4.0, it’ll call nfs40_open_expired()
> it’ll call nfs40_clear_delegation_stateid()
> it’ll call nfs_finish_clear_delegation_stateid()
> it’ll call nfs_remove_bad_delegation()
> it’ll call nfs_inode_find_state_and_recover()
> it’ll call nfs4_state_mark_reclaim_nograce() **** this will set
> RECLAIM_NOGRACE in state flags
>
> we return from recover_open() with status 0
> call nfs4_reclaim_locks() returns 0 then
> goto restart; **************  what happens is since we reset the flag
> in the state flags the whole loop starts again.
>
> Solution:
> nfs_remove_bad_delegation() is only called from
> nfs_finish_clear_delegation_stateid() which is called from either 4.0
> or 4.1 recover open functions in nograce case. In both cases, this is
> already state manager doing recovery based on the RECLAIM_NOGRACE flag
> set and it's going thru opens that need to be recovered.
>
> I propose to correct the loop by removing the call:
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 4711d04..b322823 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -632,10 +632,8 @@ void nfs_remove_bad_delegation(struct inode *inode)
>
>         nfs_revoke_delegation(inode);
>         delegation = nfs_inode_detach_delegation(inode);
> -       if (delegation) {
> -               nfs_inode_find_state_and_recover(inode, &delegation->stateid);
> +       if (delegation)
>                 nfs_free_delegation(delegation);
> -       }
>  }
>  EXPORT_SYMBOL_GPL(nfs_remove_bad_delegation);

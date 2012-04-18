Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366Ab2DRN2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 09:28:31 -0400
Date: Wed, 18 Apr 2012 09:28:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Luis Henriques <luis.henriques@canonical.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Regretion on NFS in mainline kernel
Message-ID: <20120418092822.07a4f944@tlielax.poochiereds.net>
In-Reply-To: <20120418112610.GA3979@zeus>
References: <20120418112610.GA3979@zeus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Apr 2012 12:26:10 +0100
Luis Henriques <luis.henriques@canonical.com> wrote:

> Hi,
> 
> We have a bug reporting a regression in mainline kernel.  Basically, the
> bug reporters are seeing lots of messages:
> 
> [ 48.701213] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [ 48.701990] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [ 53.696076] nfs4_reclaim_open_state: 6440 callbacks suppressed
> 
> This happens when mounting a user's home directory over NFS.
> 
> Is this a known issue being addressed at the moment?  Is there any
> information needed to help debugging the issue?
> 
> The original bug report can be found here:
> 
> http://bugs.launchpad.net/bugs/974664
> 
> And there's also a similar report for Fedora:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=811138
> 
> Cheers,

This code in nfs4_reclaim_open_state() looks wrong to me, but I'm not
that familiar with this code so I could be wrong:

-------------------[snip]--------------------
                status = ops->recover_open(sp, state);
                if (status >= 0) {
                        status = nfs4_reclaim_locks(state, ops);
                        if (status >= 0) {
                                spin_lock(&state->state_lock);
                                list_for_each_entry(lock, &state->lock_states, ls_locks) {
                                        if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
                                                pr_warn_ratelimited("NFS: "
                                                        "%s: Lock reclaim "
                                                        "failed!\n", __func__);
                                }
                                spin_unlock(&state->state_lock);
                                nfs4_put_open_state(state);
                                goto restart;
                        }
                }
-------------------[snip]--------------------

Shouldn't the status check after nfs4_reclaim_locks be reversed?

-- 
Jeff Layton <jlayton@redhat.com>

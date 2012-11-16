Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816Ab2KPQ6r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Nov 2012 11:58:47 -0500
Date: Fri, 16 Nov 2012 11:58:45 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSd state: nfs4_lock_state() and nfs4_lock_state()
Message-ID: <20121116165845.GA32183@fieldses.org>
References: <50A622AE.3080809@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50A622AE.3080809@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 16, 2012 at 03:25:34PM +0400, Stanislav Kinsbursky wrote:
> Hello, guys.
> Right now I'm looking how client_mutex can be containerised.
> And it looks like this mutex is too widely used.

Yep.

> And I can't get what it protects exactly.

Nobody does.

> I'd like to hear your opinions about the following:
> 1) Why do we need to use this mutex in
> nfsd4_load_reboot_recovery_data()? This function is called only once
> on NFS server start before launching kthreads.

I agree, that looks unnecessary.

A patch follows: note it's a two-line patch, with 20 lines of changelog
showing that I looked at what state might be shared by other threads and
explaining why I think this is safe.

I think that's what we need to do: little patches that remove it from
one or another part of the code with careful explanation of why it
works.

(I'm not completely sure this particular patch really helps reduce the
scope of the state lock that much, but maybe it's worth it.)

> 2) Look like using of this mutex can be easely moved out from read,
> write and setattr functions in nfs4proc.c to
> nfs4_preprocess_stateid_op() in nfs4state.c.

Could be.

> It it also could be
> removed from nfs4_open(), then nfs4_lock_state() and
> nfs4_lock_state() can become static.

I think you'll nfsd4_open is much more complicated.

> So the question is: why this mutex covers that much different code
> in nfsd4_open() call?

There are a number of problems.  As just one example, the state lock is
all that guarantees the open owner will survive and not, for example, be
freed before we reach the encode_seqid_op_tail in the xdr code (see the

	if (cstate->replay_owner) {
		nfs4_unlock_state();
		cstate->replay_owner = NULL;
	}

at the end of nfsd4_proc_compound).

I'm trying to get the open code fixed, but that project's on hold at the
moment.

--b.

commit 8b78ea67502007d2b2a7f5e25aeea47340eceb98
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Nov 16 11:45:12 2012 -0500

    nfsd4: remove state lock from nfsd4_load_reboot_recovery_data
    
    That function is only called under nfsd_mutex: we know that because the
    only caller is nfsd_svc, via
    
            nfsd_svc
              nfsd_startup
                nfs4_state_start
                  nfsd4_client_tracking_init
                    client_tracking_ops->init == nfsd4_load_reboot_recovery_data
    
    The shared state accessed here includes:
    
            - user_recovery_dirname: used here, modified only by
              nfs4_reset_recoverydir, which can be verified to only be
              called under nfsd_mutex.
            - filesystem state, protected by i_mutex (handwaving slightly
    	  here)
            - rec_file, reclaim_str_hashtbl, reclaim_str_hashtbl_size: other
              than here, used only from code called from nfsd or laundromat
              threads, both of which should be started only after this runs
              (see nfsd_svc) and stopped before this could run again (see
              nfsd_shutdown, called from nfsd_last_thread).
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 43295d4..ad15e77 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -424,11 +424,9 @@ nfsd4_load_reboot_recovery_data(struct net *net)
 		return -EINVAL;
 	}
 
-	nfs4_lock_state();
 	status = nfsd4_init_recdir();
 	if (!status)
 		status = nfsd4_recdir_load();
-	nfs4_unlock_state();
 	if (status)
 		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
 	return status;

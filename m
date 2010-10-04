Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:37012 "EHLO
	mx01.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753907Ab0JDKDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Oct 2010 06:03:31 -0400
Date: Mon, 4 Oct 2010 06:03:28 -0400 (EDT)
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <14582176.106.1286186603313.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
In-Reply-To: <18163799.104.1286186355944.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Subject: Re: NFS4 clients cannot reclaim locks
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> On Fri, 2010-10-01 at 07:30 -0400, Sachin Prabhu wrote:
> > NFS4 clients appear to have problems reclaiming locks after a server
> reboot. I can recreate the issue on 2.6.34.7-56.fc13.x86_64 on a
> Fedora system. 
> > 
> > The problem appears to happen in cases where after a reboot, a WRITE
> call is made just before the RENEW call. In that case, the
> NFS4ERR_STALE_STATEID is returned for the WRITE call which results in
> NFS_STATE_RECLAIM_REBOOT being set in the state flags. However the
> NFS4ERR_STALE_CLIENTID returned for the subsequent RENEW call is
> handled by 
> > nfs4_recovery_handle_error() -> nfs4_state_end_reclaim_reboot(clp); 
> 
> > which ends up setting the state flag to NFS_STATE_RECLAIM_NOGRACE
> and clearing the NFS_STATE_RECLAIM_REBOOT in
> nfs4_state_mark_reclaim_nograce(). 
> 
> Yup. I don't think we should call nfs4_state_mark_reclaim_reboot()
> here.
> 
> > The process of reclaiming the locks then seem to hit another
> roadblock in nfs4_open_expired() where it fails to open the file and
> reset the state. It ends up calling nfs4_reclaim_locks() in a loop
> with the old stateid in nfs4_reclaim_open_state().
> 
> Any idea how nfs4_open_expired() is failing? It seems that if it
> does,
> we should see an error, which would cause the lock reclaim to fail.
> 
> Also, why is the call to nfs4_reclaim_locks() looping? That too
> should
> exit in case of an error.
> 

>From instrumentation, the problem appears to happen at nfs4_open_prepare

static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
{
..
        /*
         * Check if we still need to send an OPEN call, or if we can use
         * a delegation instead.
         */

        if (data->state != NULL) {
                struct nfs_delegation *delegation;

                if (can_open_cached(data->state, data->o_arg.fmode, data->o_arg.open_flags))
                        goto out_no_action;
..
out_no_action:
        task->tk_action = NULL;

}

Here, can_open_cached returns true. The open call is never made and the old state is used.
static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs4_state_recovery_ops *ops)
{
..
restart:
..
                status = ops->recover_open(sp, state); <-- This call attempts to use cached state and status is set to 0
                if (status >= 0) {
                        status = nfs4_reclaim_locks(state, ops); <-- Attempts to reclaim locks using old stateid
        -- Here status is set to -NFS4ERR_BAD_STATEID --
                 ..
                }
                switch (status) {
..
                        case -NFS4ERR_BAD_STATEID:
                        case -NFS4ERR_RECLAIM_BAD:
                        case -NFS4ERR_RECLAIM_CONFLICT:
                                nfs4_state_mark_reclaim_nograce(sp->so_client, state);
                                break;
..
                }
                nfs4_put_open_state(state);
                goto restart;
..
}

The call to ops->recover_open() calls nfs4_open_expired(). While preparing the RPC call to OPEN, in nfs4_open_prepare(), it decides that the caches copy is valid and it attempts to use it. So nfs4_open_expired() returns 0. The subsequent call to reclaim locks using nfs4_reclaim_locks() fails with with a -NFS4ERR_BAD_STATEID. A goto statement in nfs4_reclaim_open_state() results in it looping with the same results as before.

Sachin Prabhu

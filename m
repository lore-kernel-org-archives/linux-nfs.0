Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56649 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927Ab0JENir convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 09:38:47 -0400
Subject: Re: NFS4 clients cannot reclaim locks
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <14582176.106.1286186603313.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
References: <14582176.106.1286186603313.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Oct 2010 09:38:25 -0400
Message-ID: <1286285905.3338.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-10-04 at 06:03 -0400, Sachin Prabhu wrote:
> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> > On Fri, 2010-10-01 at 07:30 -0400, Sachin Prabhu wrote:
> > > NFS4 clients appear to have problems reclaiming locks after a server
> > reboot. I can recreate the issue on 2.6.34.7-56.fc13.x86_64 on a
> > Fedora system. 
> > > 
> > > The problem appears to happen in cases where after a reboot, a WRITE
> > call is made just before the RENEW call. In that case, the
> > NFS4ERR_STALE_STATEID is returned for the WRITE call which results in
> > NFS_STATE_RECLAIM_REBOOT being set in the state flags. However the
> > NFS4ERR_STALE_CLIENTID returned for the subsequent RENEW call is
> > handled by 
> > > nfs4_recovery_handle_error() -> nfs4_state_end_reclaim_reboot(clp); 
> > 
> > > which ends up setting the state flag to NFS_STATE_RECLAIM_NOGRACE
> > and clearing the NFS_STATE_RECLAIM_REBOOT in
> > nfs4_state_mark_reclaim_nograce(). 
> > 
> > Yup. I don't think we should call nfs4_state_mark_reclaim_reboot()
> > here.

...Here is the second patch.

Cheers
  Trond
------------------------------------------------------------------------------------------------------
NFSv4: Don't call nfs4_state_mark_reclaim_reboot() from error handlers

From: Trond Myklebust <Trond.Myklebust@netapp.com>

In the case of a server reboot, the state recovery thread starts by calling
nfs4_state_end_reclaim_reboot() in order to avoid edge conditions when
the server reboots while the client is in the middle of recovery.

However, if the client has already marked the nfs4_state as requiring
reboot recovery, then the above behaviour will cause the recovery thread to
treat the open as if it was part of such an edge condition: the open will
be recovered as if it was part of a lease expiration (and all the locks
will be lost).
Fix is to remove the call to nfs4_state_mark_reclaim_reboot from
nfs4_async_handle_error(), and nfs4_handle_exception(). Instead we leave it
to the recovery thread to do this for us.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 01b4817..74aa54e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -255,9 +255,6 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			nfs4_state_mark_reclaim_nograce(clp, state);
 			goto do_state_recovery;
 		case -NFS4ERR_STALE_STATEID:
-			if (state == NULL)
-				break;
-			nfs4_state_mark_reclaim_reboot(clp, state);
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_EXPIRED:
 			goto do_state_recovery;
@@ -3493,9 +3490,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			nfs4_state_mark_reclaim_nograce(clp, state);
 			goto do_state_recovery;
 		case -NFS4ERR_STALE_STATEID:
-			if (state == NULL)
-				break;
-			nfs4_state_mark_reclaim_reboot(clp, state);
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_EXPIRED:
 			goto do_state_recovery;


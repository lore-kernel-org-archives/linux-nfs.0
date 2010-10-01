Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19895 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371Ab0JAUqm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 16:46:42 -0400
Subject: Re: NFS4 clients cannot reclaim locks
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <25362267.86.1285932646433.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
References: <25362267.86.1285932646433.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 01 Oct 2010 16:46:40 -0400
Message-ID: <1285966000.4391.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-10-01 at 07:30 -0400, Sachin Prabhu wrote:
> NFS4 clients appear to have problems reclaiming locks after a server reboot. I can recreate the issue on 2.6.34.7-56.fc13.x86_64 on a Fedora system. 
> 
> The problem appears to happen in cases where after a reboot, a WRITE call is made just before the RENEW call. In that case, the NFS4ERR_STALE_STATEID is returned for the WRITE call which results in NFS_STATE_RECLAIM_REBOOT being set in the state flags. However the NFS4ERR_STALE_CLIENTID returned for the subsequent RENEW call is handled by 
> nfs4_recovery_handle_error() -> nfs4_state_end_reclaim_reboot(clp);  
> which ends up setting the state flag to NFS_STATE_RECLAIM_NOGRACE and clearing the NFS_STATE_RECLAIM_REBOOT in nfs4_state_mark_reclaim_nograce(). 

Yup. I don't think we should call nfs4_state_mark_reclaim_reboot() here.

> The process of reclaiming the locks then seem to hit another roadblock in nfs4_open_expired() where it fails to open the file and reset the state. It ends up calling nfs4_reclaim_locks() in a loop with the old stateid in nfs4_reclaim_open_state().

Any idea how nfs4_open_expired() is failing? It seems that if it does,
we should see an error, which would cause the lock reclaim to fail.

Also, why is the call to nfs4_reclaim_locks() looping? That too should
exit in case of an error.

> By commenting out the call to nfs4_state_end_reclaim_reboot(clp) in nfs4_recovery_handle_error(), the client was able to handle this particular scenario properly.

We do need to keep the nfs4_state_end_reclaim_reboot() there. Otherwise,
we have a problem if the server reboots again while we're in the middle
of reclaiming state.

Cheers
  Trond

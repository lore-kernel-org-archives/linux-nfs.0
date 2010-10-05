Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-3.hut.fi ([130.233.228.93]:50451 "EHLO smtp-3.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855Ab0JEP2Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 11:28:24 -0400
Date: Tue, 5 Oct 2010 18:03:29 +0300 (EEST)
From: Timo Aaltonen <timo.aaltonen@aalto.fi>
To: Sachin Prabhu <sprabhu@redhat.com>
cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: NFS4 clients cannot reclaim locks
In-Reply-To: <25362267.86.1285932646433.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Message-ID: <alpine.DEB.2.00.1010051758550.7784@kosh.hut.fi>
References: <25362267.86.1285932646433.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 1 Oct 2010, Sachin Prabhu wrote:

> NFS4 clients appear to have problems reclaiming locks after a server reboot. I can recreate the issue on 2.6.34.7-56.fc13.x86_64 on a Fedora system.
>
> The problem appears to happen in cases where after a reboot, a WRITE call is made just before the RENEW call. In that case, the NFS4ERR_STALE_STATEID is returned for the WRITE call which results in NFS_STATE_RECLAIM_REBOOT being set in the state flags. However the NFS4ERR_STALE_CLIENTID returned for the subsequent RENEW call is handled by
> nfs4_recovery_handle_error() -> nfs4_state_end_reclaim_reboot(clp);
> which ends up setting the state flag to NFS_STATE_RECLAIM_NOGRACE and clearing the NFS_STATE_RECLAIM_REBOOT in nfs4_state_mark_reclaim_nograce().
>
> The process of reclaiming the locks then seem to hit another roadblock in nfs4_open_expired() where it fails to open the file and reset the state. It ends up calling nfs4_reclaim_locks() in a loop with the old stateid in nfs4_reclaim_open_state().
>
> By commenting out the call to nfs4_state_end_reclaim_reboot(clp) in nfs4_recovery_handle_error(), the client was able to handle this particular scenario properly.
>
> Has any one else seen this issue?

could this be related to the bug I was seeing with nfsv4 (now using v3 
with success):

https://bugzilla.kernel.org/show_bug.cgi?id=15973

though the error returned by the server is BAD_STATEID..


-- 
Timo Aaltonen
Systems Specialist, Aalto IT

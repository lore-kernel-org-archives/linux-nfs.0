Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:42046 "EHLO
	mx02.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756472Ab0JALas (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 07:30:48 -0400
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx02.colomx.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o91BUmBT029060
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 07:30:48 -0400
Date: Fri, 1 Oct 2010 07:30:48 -0400 (EDT)
From: Sachin Prabhu <sprabhu@redhat.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <25362267.86.1285932646433.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
In-Reply-To: <8181361.84.1285932468389.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Subject: NFS4 clients cannot reclaim locks
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS4 clients appear to have problems reclaiming locks after a server reboot. I can recreate the issue on 2.6.34.7-56.fc13.x86_64 on a Fedora system. 

The problem appears to happen in cases where after a reboot, a WRITE call is made just before the RENEW call. In that case, the NFS4ERR_STALE_STATEID is returned for the WRITE call which results in NFS_STATE_RECLAIM_REBOOT being set in the state flags. However the NFS4ERR_STALE_CLIENTID returned for the subsequent RENEW call is handled by 
nfs4_recovery_handle_error() -> nfs4_state_end_reclaim_reboot(clp);  
which ends up setting the state flag to NFS_STATE_RECLAIM_NOGRACE and clearing the NFS_STATE_RECLAIM_REBOOT in nfs4_state_mark_reclaim_nograce(). 

The process of reclaiming the locks then seem to hit another roadblock in nfs4_open_expired() where it fails to open the file and reset the state. It ends up calling nfs4_reclaim_locks() in a loop with the old stateid in nfs4_reclaim_open_state().

By commenting out the call to nfs4_state_end_reclaim_reboot(clp) in nfs4_recovery_handle_error(), the client was able to handle this particular scenario properly.

Has any one else seen this issue?

Sachin Prabhu

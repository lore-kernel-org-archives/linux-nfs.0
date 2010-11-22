Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx06.aalto.fi ([130.233.222.105]:40396 "EHLO mx06.aalto.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753390Ab0KVQOz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Nov 2010 11:14:55 -0500
Received: from mx06.aalto.fi (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 7787D80719
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 18:02:38 +0200 (EET)
Received: from EXHUB04.org.aalto.fi (ex-hub04.org.aalto.fi [130.233.222.117])
	by mx06.aalto.fi (Postfix) with ESMTP id 699808070E
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 18:02:38 +0200 (EET)
Date: Mon, 22 Nov 2010 18:02:38 +0200
From: Timo Aaltonen <timo.aaltonen@aalto.fi>
To: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: NFS4 clients cannot reclaim locks
In-Reply-To: <alpine.DEB.2.00.1010051758550.7784@kosh.hut.fi>
Message-ID: <alpine.DEB.2.00.1011221800460.4563@kosh.org.aalto.fi>
References: <25362267.86.1285932646433.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com> <alpine.DEB.2.00.1010051758550.7784@kosh.hut.fi>
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 5 Oct 2010, Timo Aaltonen wrote:

> On Fri, 1 Oct 2010, Sachin Prabhu wrote:
>
>> NFS4 clients appear to have problems reclaiming locks after a server 
>> reboot. I can recreate the issue on 2.6.34.7-56.fc13.x86_64 on a Fedora 
>> system.
>> 
>> The problem appears to happen in cases where after a reboot, a WRITE call 
>> is made just before the RENEW call. In that case, the NFS4ERR_STALE_STATEID 
>> is returned for the WRITE call which results in NFS_STATE_RECLAIM_REBOOT 
>> being set in the state flags. However the NFS4ERR_STALE_CLIENTID returned 
>> for the subsequent RENEW call is handled by
>> nfs4_recovery_handle_error() -> nfs4_state_end_reclaim_reboot(clp);
>> which ends up setting the state flag to NFS_STATE_RECLAIM_NOGRACE and 
>> clearing the NFS_STATE_RECLAIM_REBOOT in nfs4_state_mark_reclaim_nograce().
>> 
>> The process of reclaiming the locks then seem to hit another roadblock in 
>> nfs4_open_expired() where it fails to open the file and reset the state. It 
>> ends up calling nfs4_reclaim_locks() in a loop with the old stateid in 
>> nfs4_reclaim_open_state().
>> 
>> By commenting out the call to nfs4_state_end_reclaim_reboot(clp) in 
>> nfs4_recovery_handle_error(), the client was able to handle this particular 
>> scenario properly.
>> 
>> Has any one else seen this issue?
>
> could this be related to the bug I was seeing with nfsv4 (now using v3 with 
> success):
>
> https://bugzilla.kernel.org/show_bug.cgi?id=15973
>
> though the error returned by the server is BAD_STATEID..

At least testing .37rc2 has so far been positive, suggesting that the bug 
is fixed there.


-- 
Timo Aaltonen
Systems Specialist, Aalto IT

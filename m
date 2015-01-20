Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fr-hpida-esg-02.alcatel-lucent.com ([135.245.210.21]:49857 "EHLO
	smtp-fr.alcatel-lucent.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbbATINh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jan 2015 03:13:37 -0500
Received: from us70uusmtp3.zam.alcatel-lucent.com (unknown [135.5.2.65])
	by Websense Email Security Gateway with ESMTPS id AD5E3DDDA9B23
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 08:03:09 +0000 (GMT)
Received: from US70UWXCHHUB02.zam.alcatel-lucent.com (us70uwxchhub02.zam.alcatel-lucent.com [135.5.2.49])
	by us70uusmtp3.zam.alcatel-lucent.com (GMO) with ESMTP id t0K83ACb018714
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 03:03:10 -0500
Message-ID: <54BE0B6B.5090609@alcatel-lucent.com>
Date: Tue, 20 Jan 2015 01:01:47 -0700
From: Aaron Pace <Aaron.Pace@alcatel-lucent.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: Type mismatch causing  stale client loop
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I didn't see this issue reported already, but then, I didn't do a 
terribly exhaustive search, so my apologies if this is already known.

I noticed that I was getting looping stale client errors while trying to 
mount an NFS share (example below):

[  965.926293] nfsd_dispatch: vers 4 proc 1
[  965.973373] nfsv4 compound op #1/1: 35 (OP_SETCLIENTID)
[  966.036158] renewing client (clientid 6f1df70d/00002580)
[  966.099880] nfsv4 compound op ffff880450d51080 opcnt 1 #1: 35: status 0
[  966.179190] nfsv4 compound returned 0
[  966.223447] nfsd_dispatch: vers 4 proc 1
[  966.270475] nfsv4 compound op #1/1: 36 (OP_SETCLIENTID_CONFIRM)
[  966.341487] NFSD stale clientid (6f1df70d/00002580) boot_time 16f1df70d
[  966.420791] nfsv4 compound op ffff880450d51080 opcnt 1 #1: 36: status 
10022
[  966.504419] nfsv4 compound returned 10022
[  966.552738] nfsd_dispatch: vers 4 proc 1

The 'stale' error comes from nfs4state.c:

static int
STALE_CLIENTID(clientid_t *clid, struct nfsd_net *nn)
{
     if (clid->cl_boot == nn->boot_time)
         return 0;
     dprintk("NFSD stale clientid (%08x/%08x) boot_time %08lx\n",
         clid->cl_boot, clid->cl_id, nn->boot_time);
     return 1;
}

I thought to myself -- 'Self, it seems statistically unlikely that a 
legitimately mismatching cl_boot and nn->boot_time would have identical 
lower 32-bits'.
As it turns out, nn->boot time is defined as time_t (unsigned long / 64 
bits on a 64 bit platform), and cl_boot is defined as a u32.
My system time, as you may have guessed, was wildly invalid (2025-ish).  
However, this does appear to be a legitimate issue in a 64-bit kernel 
that will crop up in a few years.  I was working in 3.10, but I verified 
that the definitions are identical in the current 3.19 release candidate.
Sadly, I don't have the bandwidth (or the expertise) to really 
understand the ramifications of what seems to be the logical next step, 
changing cl_boot to be time_t instead of u32.  I am hoping that this 
will be trivial to look at for someone on this list.

Thanks,
-Aaron Pace



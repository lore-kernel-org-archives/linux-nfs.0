Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38579 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbbATPSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2015 10:18:18 -0500
Date: Tue, 20 Jan 2015 10:18:15 -0500
To: Aaron Pace <Aaron.Pace@alcatel-lucent.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Type mismatch causing  stale client loop
Message-ID: <20150120151815.GD7899@fieldses.org>
References: <54BE0B6B.5090609@alcatel-lucent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54BE0B6B.5090609@alcatel-lucent.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 20, 2015 at 01:01:47AM -0700, Aaron Pace wrote:
> Hello,
> 
> I didn't see this issue reported already, but then, I didn't do a
> terribly exhaustive search, so my apologies if this is already
> known.
> 
> I noticed that I was getting looping stale client errors while
> trying to mount an NFS share (example below):
> 
> [  965.926293] nfsd_dispatch: vers 4 proc 1
> [  965.973373] nfsv4 compound op #1/1: 35 (OP_SETCLIENTID)
> [  966.036158] renewing client (clientid 6f1df70d/00002580)
> [  966.099880] nfsv4 compound op ffff880450d51080 opcnt 1 #1: 35: status 0
> [  966.179190] nfsv4 compound returned 0
> [  966.223447] nfsd_dispatch: vers 4 proc 1
> [  966.270475] nfsv4 compound op #1/1: 36 (OP_SETCLIENTID_CONFIRM)
> [  966.341487] NFSD stale clientid (6f1df70d/00002580) boot_time 16f1df70d
> [  966.420791] nfsv4 compound op ffff880450d51080 opcnt 1 #1: 36:
> status 10022
> [  966.504419] nfsv4 compound returned 10022
> [  966.552738] nfsd_dispatch: vers 4 proc 1
> 
> The 'stale' error comes from nfs4state.c:
> 
> static int
> STALE_CLIENTID(clientid_t *clid, struct nfsd_net *nn)
> {
>     if (clid->cl_boot == nn->boot_time)
>         return 0;
>     dprintk("NFSD stale clientid (%08x/%08x) boot_time %08lx\n",
>         clid->cl_boot, clid->cl_id, nn->boot_time);
>     return 1;
> }
> 
> I thought to myself -- 'Self, it seems statistically unlikely that a
> legitimately mismatching cl_boot and nn->boot_time would have
> identical lower 32-bits'.
> As it turns out, nn->boot time is defined as time_t (unsigned long /
> 64 bits on a 64 bit platform),

I believe it's signed.

> and cl_boot is defined as a u32.
> My system time, as you may have guessed, was wildly invalid
> (2025-ish).  However, this does appear to be a legitimate issue in a
> 64-bit kernel that will crop up in a few years.  I was working in
> 3.10, but I verified that the definitions are identical in the
> current 3.19 release candidate.
> Sadly, I don't have the bandwidth (or the expertise) to really
> understand the ramifications of what seems to be the logical next
> step, changing cl_boot to be time_t instead of u32.  I am hoping
> that this will be trivial to look at for someone on this list.

cl_boot is an on-the-wire field with space only for 32 bits.

So I think we want to check that clid->cl_boot and nn->boot_time for
equality mod 2^32 instead of for strict equality.

That requires assuming that a client will not attempt to reuse stale
state given out on a previous server boot that happened some exact
multiple of 2^32 seconds (130-some years?) ago.  I'm comfortable with
that assumption....

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46846 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933692AbcBYT62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Feb 2016 14:58:28 -0500
Date: Thu, 25 Feb 2016 14:58:27 -0500
To: Jason L Tibbitts III <tibbs@math.uh.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20160225195827.GC23315@fieldses.org>
References: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 24, 2016 at 03:43:45PM -0600, Jason L Tibbitts III wrote:
> My NFS infrastructure has servers running current RHEL7.2 (mostly kernel
> 3.10.0-327.4.5.el7 with a one-line patch needed to fix a soft lockup in
> nfs4_laundromat) and clients running current Fedora 23
> (4.3.5-300.fc23.x86_64).  Everything is mounted NFS4.1 with sec=krb5p.
> 
> Occasionally a client will get into a state where it just hammers the
> server with network traffic, sometimes at full line rate, with:
> 
> NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> 
> spewed to the log about 500 times a second.  The load goes up quite a
> bit (to 5-7 or so).  The machine isn't doing anything and there isn't
> even a user logged in.  However, there are always a few user processes
> hanging around, usually kwin_x11 for whatever reason.  (My guess is
> because of a lock on ~/.Xauthority.)
> 
> When I kill those user processes, this is logged once:
> 
> NFS: nfs4_reclaim_open_state: unhandled error -10068
> 
> -10068 is NFS4ERR_RETRY_UNCACHED_REP.

The only place the server sets that error is in
fs/nfsd/nfs4state.c:nfsd4_enc_sequence_replay.

If the server's correct, then the client attempted to resend a request
that the server was not required to cache.  In which case
NFS4ERR_RETRY_UNCACHED_REP is a valid error, and the client should give
up (or retry with a new slot/seqid?).

In any case, something's wrong with the 4.1 reply caching logic on
client or server.....

> Unfortunately I did not grab any of that traffic (I just wanted it to
> stop).  This happens to me periodically so I'll be sure to do that when
> it hits again.

OK, that'd be helpful.  Unfortunately what would probably be *most*
helpful would be the traffic that lead up to this--by the time the
client and server get into this loop the interesting problem may have
already happened--but just seeing the loop may be useful too.

--b.

> One theory is that this is related to a user's kerberos ticket
> expiring.  I see some hits when I search for the line that's spewed, but
> they're either not recent or or weren't reproducible.  I don't find any
> hits for that specific unhandled error.
> 
>  - J<
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

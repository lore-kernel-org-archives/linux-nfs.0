Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.math.uh.edu ([129.7.128.33]:44054 "EHLO mx2.math.uh.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758714AbcBXWJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 17:09:32 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
	by mx2.math.uh.edu with esmtp (Exim 4.85)
	(envelope-from <tibbs@math.uh.edu>)
	id 1aYhDl-0000QN-IX
	for linux-nfs@vger.kernel.org; Wed, 24 Feb 2016 15:43:46 -0600
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: linux-nfs@vger.kernel.org
Subject: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Date: Wed, 24 Feb 2016 15:43:45 -0600
Message-ID: <ufafuwhlr72.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My NFS infrastructure has servers running current RHEL7.2 (mostly kernel
3.10.0-327.4.5.el7 with a one-line patch needed to fix a soft lockup in
nfs4_laundromat) and clients running current Fedora 23
(4.3.5-300.fc23.x86_64).  Everything is mounted NFS4.1 with sec=krb5p.

Occasionally a client will get into a state where it just hammers the
server with network traffic, sometimes at full line rate, with:

NFS: nfs4_reclaim_open_state: Lock reclaim failed!

spewed to the log about 500 times a second.  The load goes up quite a
bit (to 5-7 or so).  The machine isn't doing anything and there isn't
even a user logged in.  However, there are always a few user processes
hanging around, usually kwin_x11 for whatever reason.  (My guess is
because of a lock on ~/.Xauthority.)

When I kill those user processes, this is logged once:

NFS: nfs4_reclaim_open_state: unhandled error -10068

-10068 is NFS4ERR_RETRY_UNCACHED_REP.

Unfortunately I did not grab any of that traffic (I just wanted it to
stop).  This happens to me periodically so I'll be sure to do that when
it hits again.

One theory is that this is related to a user's kerberos ticket
expiring.  I see some hits when I search for the line that's spewed, but
they're either not recent or or weren't reproducible.  I don't find any
hits for that specific unhandled error.

 - J<

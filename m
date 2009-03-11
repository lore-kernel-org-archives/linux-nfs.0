From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: miscellaneous nfsd4 state changes
Date: Tue, 10 Mar 2009 20:26:48 -0400
Message-ID: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44034 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
Received: from bfields by pickle.fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1LhCHm-0000tV-Bq
	for linux-nfs@vger.kernel.org; Tue, 10 Mar 2009 20:27:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm trying to move the callback code to asynchronous rpc calls, fix some
miscellaneous problems with the callback code, and break up the nfsv4
state lock.

But the callback changes aren't done yet, and are still just in my local
tree; and the locking fixup is still just on paper.

In the meantime, these are some smaller cleanups (and one small locking
change) done in preparation; these are queued up for 2.6.30, barring
any objections.

Beyond this, the (vague) longer-term plan:

	- Make the callback rpc's asynchronous, and remove the separate
	  kthreads.
	- Add a list of outstanding callbacks to the nfs4 client, for
	  two purposes:
		- to allow restarting those calls after the rpc callback
		  client is destroyed and replaced with a new one (as
		  may happen in the setclientid case that changes the
		  callback channel); and
		- to keep track of whether any callbacks are currently
		  taking too long (which I'm provisionally defining as
		  longer than lease_time/10 (or a second, if that's
		  larger)).  When callbacks are taking too long, we
		  start returning cb_channel_down errors to the client's
		  renews, and we stop handing out delegations.  Having
		  the full list of pending callbacks available may make
		  it easier to decide when to re-enable delegations
		  (which we should probably wait to do till *all*
		  pending too-slow callbacks have been replied to,
		  rather than just one of them).

For locking:

	- Create a semaphore for each stateid, to be taken on the
	  seqid-mutating ops.
	- Try to rely on spinlocks otherwise; I haven't figured out
	  quite what's required yet.

--b.

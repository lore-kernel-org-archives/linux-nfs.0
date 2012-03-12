Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755789Ab2CLPRI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 11:17:08 -0400
Date: Mon, 12 Mar 2012 11:17:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [bfields: [LSF/MM TOPIC] fileservers' filesystem wishlist]
Message-ID: <20120312151707.GD4752@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies, this is late for a topic proposal--and I'm not really certain
whether it merits a separate "topic" or whether it's really just an
add-on to Ric's "linux servers as a storage server - what's missing?".

In any case, I'd love to have a slot to run through a file servers'
filesystem wishlist; probably a slide or two each for features such as:

	- change attributes
	- delegations/opLocks
	- share locks
	- deleted-file recovery/server-side sillyrename
	- lock recovery

with a brief summary of each (and of current status in cases where we
have a partial solution already).

Plus a little time to discuss each feature, depending on interest.

My main interest is knfsd, but I'd also like to look at what we could do
for userspace (SMB and NFS) servers.

I recall doing something like this (five years ago?) at the first LSF,
and it was quite helpful (though some of the same problems remain).

--b.

(Resent to correct cc: list, sorry!)

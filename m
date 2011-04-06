Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708Ab1DFXGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:32 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Q7bo0-0001j6-66
	for linux-nfs@vger.kernel.org; Wed, 06 Apr 2011 19:06:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: server tcp performance patches
Date: Wed,  6 Apr 2011 19:06:19 -0400
Message-Id: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We previously attempted to turn on autotuning of nfsd's tcp receive
buffers, enabling better performance on large bandwidth-delay-product
networks, but ran into some regressions on local gigabit networks.

At the time Trond proposed modifying the server to receive partial rpc
calls as they arrive instead of waiting for the entire request to
arrive, reasoning that that would a) free up receive buffer space
sooner, causing the server to advertise a larger window soon, and b)
avoid theoretical deadlocks possible if the receive buffer ever fell
below the minimum required to hold a request.

That seemed to solve the observed regression, but we didn't completely
understand why, so I put off applying the patches.

I still don't completely understand the cause of the original
regression, but it seems like a reasonable thing to do anyway, and
solves an immediate problem, so I've updated Trond's original patch (and
split it up slightly)--the main changes required were just to adapt to
the 4.1 backchannel reply receive code.

I'm considering queueing this up for 2.6.40.

--b.

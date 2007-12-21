From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/6] Intro: convert lockd to kthread and fix use-after-free (try #4)
Date: Fri, 21 Dec 2007 10:28:04 -0500
Message-ID: <1198250890-25571-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbXLUP2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2007 10:28:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the third patchset to fix the use-after-free problem in lockd
which we originally discussed back in October. The main problem is
detailed in the last patch of the series. Along the way, Christoph
Hellwig mentioned that it would be advantageous to convert lockd to use
the kthread API. This patch set first makes that change and then
patches it to actually fix the use after free problem. It also fixes
a couple of minor bugs in the current lockd implementation.

The main change from the last patchset is that I've dropped the first
patch that changed svc_pool_map_set_cpumask, since it's no longer
strictly needed. I've also done some style cleanups recommended by
checkpatch.pl.

I've done some basic smoke testing and everything seems to work as
expected. I've also tested this against the reproducer that I have for
the use-after-free problem and this does fix it. I've tried to make
this cleanly bisectable, but have only really tested the final result.

I'd like to see this soak in nfs-2.6 git tree for a bit and then be
considered for 2.6.25. Thoughts?

Thanks,

Signed-off-by: Jeff Layton <jlayton@redhat.com>


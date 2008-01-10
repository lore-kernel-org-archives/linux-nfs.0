From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] Intro: convert lockd to kthread and fix use-after-free (try #7)
Date: Thu, 10 Jan 2008 13:01:31 -0500
Message-ID: <1199988096-19700-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757096AbYAJSC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 13:02:26 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the seventh patchset to fix the use-after-free problem in lockd
which we originally discussed back in October. Along the way, Christoph
Hellwig mentioned that it would be advantageous to convert lockd to use
the kthread API. This patch set first makes that change and then patches
it to actually fix the use after free problem. It also fixes a couple of
minor bugs in the current lockd implementation.

This patch takes a different approach in fixing the use-after-free than
earlier ones. Instead of trying to ensure that lockd stays up until all
callbacks complete, this patch tries to just make sure that all RPC's
are canceled when lockd is requested to come down. With this change
we no longer need to have lockd_down signal lockd, we don't need to do
any extra reference counting, and can use the more conventional kthread
functions to handle lockd shutdown.

I've done some very basic testing and everything seems to work as
expected.  I've also tested this against the reproducer that I have for
the use-after-free problem and this does fix it. I've tried to make this
cleanly bisectable, but have only really tested the final result.

Many thanks to Trond Myklebust, Chuck Lever, Neil Brown and Christoph
Hellwig for their guidance on this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>


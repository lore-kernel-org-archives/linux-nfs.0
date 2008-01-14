From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/4] Intro: convert lockd to kthread and fix use-after-free (try #8)
Date: Mon, 14 Jan 2008 09:05:14 -0500
Message-ID: <1200319518-22422-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233AbYANOFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 09:05:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the eighth patchset to fix the use-after-free problem in lockd
which we originally discussed back in October. Along the way, Christoph
Hellwig mentioned that it would be advantageous to convert lockd to use
the kthread API. This patch set first makes that change and then patches
it to actually fix the use after free problem. 

The main changes from the last patchset are:

- dropped the try_to_freeze() patch. svc_recv calls try_to_freeze() too,
  so that wasn't really necessary. I added a comment to clarify that for
  future reference.

- fixed a race whereby make_socks() could get called with a null
  nlmsvc_serv pointer and cause an oops. Thanks to Christoph Hellwig for
  the original patch.

- moved lock_kernel() down slightly in the lockd() function, and
  unlock_kernel() up. It's not much of a change, but it's a start. I
  also added a FIXME comment that we should fix lockd to not run under
  the BKL. Perhaps someone can clarify why lockd() does this.

I've done some very basic testing and everything seems to work as
expected.  I've also tested this against the reproducer that I have for
the use-after-free problem and this does fix it. I've tried to make this
cleanly bisectable, but have only really tested the final result.

Many thanks to Trond Myklebust, Chuck Lever, Neil Brown and Christoph
Hellwig for their guidance on this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>


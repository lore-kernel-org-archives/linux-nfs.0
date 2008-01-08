From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/6] Intro: convert lockd to kthread and fix use-after-free (try #6)
Date: Tue,  8 Jan 2008 14:33:12 -0500
Message-ID: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757912AbYAHTeI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 14:34:08 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the sixth patchset to fix the use-after-free problem in lockd
which we originally discussed back in October. The main problem is
detailed in the last patch of the series. Along the way, Christoph
Hellwig mentioned that it would be advantageous to convert lockd to use
the kthread API. This patch set first makes that change and then patches
it to actually fix the use after free problem. It also fixes a couple of
minor bugs in the current lockd implementation.

Most of the changes from the last patchset were ones suggested by
Neil Brown and are:

+ fix a preexisting bug that would cause a NULL pointer dereference if
  the later kmallocs failed in svc_prepare_thread

+ additional comments to explain the rationale behind nlmsvc_ref
  increments and decrements

+ removed module_get/put from lockd(). It should no longer be necessary
  and isn't safe

+ sanity checks in lockd_down have been changed to BUG() calls. They
  should never happen and if they do, then something is very wrong.

I've done some basic testing and everything seems to work as expected.
I've also tested this against the reproducer that I have for the
use-after-free problem and this does fix it. I've tried to make this
cleanly bisectable, but have only really tested the final result.

Many thanks to Trond Myklebust, Chuck Lever, Neil Brown and Christoph
Hellwig for their guidance on this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>


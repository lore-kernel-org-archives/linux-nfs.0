Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47466 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263Ab2K1BMV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 20:12:21 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Wed, 28 Nov 2012 12:11:22 +1100
Subject: [PATCH 0/3] Make size of gssd_proc fd array a little more dynamic
Cc: linux-nfs@vger.kernel.org
Message-ID: <20121128010939.2475.13123.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We recently had a request to raise the number of fds that gssd can
work with - again.

Rather than just change the hard-coded number I seemed to make sense
to have it depend on RLIMIT_NOFILE - as poll won't work with more than
that anyway.
So the default becomes 1024, but it is easily raised further without
code change.

These patches implement that.

NeilBrown


---

Neil Brown (3):
      gssd_proc: use pollsize, not FD_ALLOC_BLOCK, in get_poll_index().
      gssd_proc: remove pointless test against FD_ALLOC_BLOCK in process_pipedir
      gssd: base the size of the fd array on the RLIMIT_NOFILE limit.


 utils/gssd/gssd_proc.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

-- 
Signature


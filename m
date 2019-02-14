Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CF6EC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 17:56:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2580A21928
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 17:56:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388084AbfBNR44 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 12:56:56 -0500
Received: from fieldses.org ([173.255.197.46]:37418 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726337AbfBNR44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Feb 2019 12:56:56 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id AD5B31CE7; Thu, 14 Feb 2019 12:56:55 -0500 (EST)
Date:   Thu, 14 Feb 2019 12:56:55 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Donald Buczek <buczek@molgen.mpg.de>
Cc:     linux-nfs@vger.kernel.org, it+nfs@molgen.mpg.de
Subject: [PATCH] Revert "nfsd4: return default lease period"
Message-ID: <20190214175655.GA9216@fieldses.org>
References: <480bf69d-4651-aaac-2b85-634561c579c8@molgen.mpg.de>
 <20190208020322.GA9482@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208020322.GA9482@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

This reverts commit d6ebf5088f09472c1136cd506bdc27034a6763f8.

I forgot that the kernel's default lease period should never be
decreased!

After a kernel upgrade, the kernel has no way of knowing on its own what
the previous lease time was.  Unless userspace tells it otherwise, it
will assume the previous lease period was the same.

So if we decrease this value in a kernel upgrade, we end up enforcing a
grace period that's too short, and clients will fail to reclaim state in
time.  Symptoms may include EIO and log messages like "NFS:
nfs4_reclaim_open_state: Lock reclaim failed!"

There was no real justification for the lease period decrease anyway.

Reported-by: Donald Buczek <buczek@molgen.mpg.de>
Fixes: d6ebf5088f09 "nfsd4: return default lease period"
Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

On Thu, Feb 07, 2019 at 09:03:22PM -0500, bfields wrote:
> On Thu, Feb 07, 2019 at 12:48:41PM +0100, Donald Buczek wrote:
> > As an experiment, I've also restarted a server with the lease time
> > decrement from 90 to 45 seconds, but the grace period fixed to
> > 90 seconds. Now the client got NFS4ERR_STALE_CLIENTID  but still did
> > not query the server for a new lease_time and continued to send RENEWs
> > in 60 second intervals.

So this doesn't fix that client bug, but it does fix the server.

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b33f9785b756..72a7681f4046 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1239,8 +1239,8 @@ static __net_init int nfsd_init_net(struct net *net)
 	retval = nfsd_idmap_init(net);
 	if (retval)
 		goto out_idmap_error;
-	nn->nfsd4_lease = 45;	/* default lease time */
-	nn->nfsd4_grace = 45;
+	nn->nfsd4_lease = 90;	/* default lease time */
+	nn->nfsd4_grace = 90;
 	nn->somebody_reclaimed = false;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
-- 
2.20.1


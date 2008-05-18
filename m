From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove signaling for shutdown
Date: Sat, 17 May 2008 22:35:11 -0400
Message-ID: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbYERCfR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 May 2008 22:35:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

knfsd is the last NFS-related kernel thread that does not use the
kthread API. This patchset represents a first pass at converting it. It
seems to work, but changes the shutdown interface. knfsd currently
allows signals to tell it when to come down.

My main question is...how tied to this shutdown method are we? We can
also take down nfsd by having people run:

     # rpc.nfsd 0

...which basically does:

     # echo 0 > /proc/fs/nfsd/threads

...so we don't think we *have* to use signals here. Is signaling
something we can reasonably eliminate? In addition to making the code a
bit simpler and cleaner, I think it will also eliminate this race:

    http://lkml.org/lkml/2007/8/2/462

If this isn't feasible, then I can add the signaling back in, but am not
sure whether we can eliminate the race without adding more locking.

If we can do this, we may need to provide an alternate way to specify
that we want to take down all nfsd's but not flush the export table.
Currently that's done with a SIGHUP, but the value of this facility is
not clear to me since the kernel can just do another upcall.

Comments and suggestions appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>


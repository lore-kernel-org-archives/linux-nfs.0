Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687Ab1IUP65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 11:58:57 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8LFwvxD003727
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 11:58:57 -0400
Received: from tlielax.poochiereds.net (vpn-11-239.rdu.redhat.com [10.11.11.239])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p8LFwuUS005081
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 11:58:56 -0400
Date: Wed, 21 Sep 2011 11:58:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: regression when opening directories on NFSv4
Message-ID: <20110921115854.02605a7f@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We had a regression reported against RHEL concerning the opening of
directories and it looks like that same problem is in current mainline
code too. If you do the following on a directory that is not yet in the
dcache you get an EISDIR error:

     open("/mnt/nfs/dir1", O_RDONLY)         = -1 EISDIR (Is a directory)

If however, you stat the directory first, the open works. The
difference seems to be that in the first case we're going through the
lookup codepath, and in the second we go through d_revalidate.

In the first case, we send an OPEN call to the server and it responds
with NFS4ERR_ISDIR. That gets translated to -EISDIR, and returned to
userspace. It wasn't always this way though, and I think the regression
was introduced in commit d953126a2.

That patch was added to fix an oops due to a buggy server, and I'm
unclear on how best to fix this. It seems like we need to allow the
server to fall back to doing a normal lookup when we get -EISDIR on the
OPEN call, but how do we ensure that we don't end up with the same oops
from that server bug?

Thoughts?
-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46555 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755655AbZKXCyI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 21:54:08 -0500
Date: Tue, 24 Nov 2009 13:56:03 +1100
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFS4ERR_FILE_OPEN handling in Linux/NFS
Message-ID: <20091124135603.6434548f@notabene.brown>
In-Reply-To: <1258747113.2494.81.camel@localhost>
References: <20091117042004.1563.95871.stgit@notabene.brown>
	<20091117042123.1563.20912.stgit@notabene.brown>
	<1258747113.2494.81.camel@localhost>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 20 Nov 2009 14:58:33 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> If you add an entry for NFS4ERR_FILE_OPEN into nfs4_stat_to_errno(),
> then the result of the RPC call will be -EBUSY rather than
> NFS4ERR_FILE_OPEN.
> In that case, I can't see how the NFS4ERR_FILE_OPEN is being
> propagated to nfs4_handle_exception().
> 
> See
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=52567b03ca38b6e556ced450d64dba8d66e23b0e
> for how we fixed up a similar problem with NFS4ERR_RESOURCE...

Thanks.  That all makes lots of sense.
I don't think I need nfs4_map_errors to understand NFS4ERR_FILE_OPEN
in this case as it can be completely handled in nfs4_handle_exception.

So how about this:

Thanks,
NeilBrown


From: NeilBrown <neilb@suse.de>
Date: Tue, 24 Nov 2009 13:50:52 +1100
Subject: [PATCH] NFS4ERR_FILE_OPEN handling in Linux/NFS

NFS4ERR_FILE_OPEN is return by the server when an operation cannot be
performed because the file is currently open and local (to the server)
semantics prohibit the operation while the file is open.
A typical case is a RENAME operation on an MS-Windows platform, which
prevents rename while the file is open.

While it is possible that such a condition is transitory, it is also
very possible that the file will be held open for an extended period
of time thus preventing the operation.

The current behaviour of Linux/NFS is to retry the operation
indefinitely.  This is not appropriate - we do not expect a rename to
take an arbitrary amount of time to complete.

Rather, and error should be returned.  The most obvious error code
would be EBUSY, which is a legal at least for 'rename' and 'unlink',
and accurately captures the reason for the error.

This patch allows a few retries until about 2 seconds have elapsed,
then returns EBUSY.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/nfs4proc.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff37454..f37f466 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -275,6 +275,13 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			/* FALLTHROUGH */
 #endif /* !defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
+			if (exception->timeout > HZ) {
+				/* We have retried a decent amount, time to
+				 * fail
+				 */
+				err = -EBUSY;
+				break;
+			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
 			ret = nfs4_delay(server->client, &exception->timeout);
-- 
1.6.4.3


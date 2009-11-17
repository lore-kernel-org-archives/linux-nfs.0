From: NeilBrown <neilb@suse.de>
Subject: [PATCH 1/2] NFS4ERR_FILE_OPEN handling in Linux/NFS
Date: Tue, 17 Nov 2009 15:21:24 +1100
Message-ID: <20091117042123.1563.20912.stgit@notabene.brown>
References: <20091117042004.1563.95871.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:46279 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753824AbZKQEVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 23:21:25 -0500
In-Reply-To: <20091117042004.1563.95871.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4ERR_FILE_OPEN is returned by the server when an operation cannot be
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

Rather, an error should be returned.  The most obvious error code
would be EBUSY, which is a legal at least for 'rename' and 'unlink',
and accurately captures the reason for the error.

This patch allows a few retries until about 2 seconds have elapsed,
then returns EBUSY.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfs/nfs4proc.c |    5 +++++
 fs/nfs/nfs4xdr.c  |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff37454..be26c0c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -275,6 +275,11 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			/* FALLTHROUGH */
 #endif /* !defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
+			if (exception->timeout > HZ)
+				/* We have retried a decent amount, time to
+				 * fail
+				 */
+				break;
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
 			ret = nfs4_delay(server->client, &exception->timeout);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 20b4e30..e50246d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5684,6 +5684,7 @@ static struct {
 	{ NFS4ERR_SYMLINK,	-ELOOP		},
 	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
 	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
+	{ NFS4ERR_FILE_OPEN,	-EBUSY		},
 	{ NFS4ERR_WRONGSEC,	-EPERM		}, /* FIXME: this needs
 						    * to be handled by a
 						    * middle-layer.



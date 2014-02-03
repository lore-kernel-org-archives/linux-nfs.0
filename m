Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:56024 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaBCVDA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 16:03:00 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] NFS: incorrect "port=" value in /proc/mounts
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 03 Feb 2014 16:02:58 -0500
Message-ID: <20140203210258.3533.80680.stgit@manet.1015granger.net>
In-Reply-To: <20140203205903.3533.39213.stgit@manet.1015granger.net>
References: <20140203205903.3533.39213.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mounting with "-o vers=4" shows the following in /proc/mounts:

  ... namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2, ...
                                ^^^^^^

The default port, 2049, was actually used, but was never recorded
in this mount point's nfs_server.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=69241
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: <stable@vger.kernel.org>
---

 fs/nfs/client.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1d09289..2bb6dee 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -924,6 +924,7 @@ void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *sour
 	target->flags = source->flags;
 	target->rsize = source->rsize;
 	target->wsize = source->wsize;
+	target->port = source->port;
 	target->acregmin = source->acregmin;
 	target->acregmax = source->acregmax;
 	target->acdirmin = source->acdirmin;


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:60415 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbaCLQwR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:52:17 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so14782951igc.2
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:52:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] NFS: incorrect "port=" value in /proc/mounts
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:52:15 -0400
Message-ID: <20140312165215.15349.70055.stgit@manet.1015granger.net>
In-Reply-To: <20140312164620.15349.22643.stgit@manet.1015granger.net>
References: <20140312164620.15349.22643.stgit@manet.1015granger.net>
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


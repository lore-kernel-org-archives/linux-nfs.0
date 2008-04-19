From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 32/33] NFS: remove duplicate flags assignment from
	nfs_validate_mount_data
Date: Sat, 19 Apr 2008 16:40:55 -0400
Message-ID: <20080419204055.14124.38784.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757040AbYDSUuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:35 -0400
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7c13ce7..20a1cb1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1273,7 +1273,6 @@ static int nfs_validate_mount_data(void *options,
 		args->flags		= data->flags;
 		args->rsize		= data->rsize;
 		args->wsize		= data->wsize;
-		args->flags		= data->flags;
 		args->timeo		= data->timeo;
 		args->retrans		= data->retrans;
 		args->acregmin		= data->acregmin;


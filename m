From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 108/112] NFS: Address memory leaks in the NFS client mount
	option parser
Date: Fri, 25 Jan 2008 11:38:02 -0500
Message-ID: <20080125163802.31887.61424.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53199 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262AbYAYRAg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:36 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0LnE010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:34 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

David Howells noticed that repeating the same mount option twice during an
NFS mount request can result in orphaned memory in certain cases.

Only the client_address and mount_server.hostname strings are initialized
in the mount parsing loop, so those appear to be the only two pointers that
might be written over by repeating a mount option.  The strings in the
nfs_server section of the nfs_parsed_mount_data structure are set only once
after the options are parsed, thus these are not susceptible to being
overwritten.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0d1bc61..22c49c0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1006,12 +1006,14 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
+			kfree(mnt->client_address);
 			mnt->client_address = string;
 			break;
 		case Opt_mounthost:
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
+			kfree(mnt->mount_server.hostname);
 			mnt->mount_server.hostname = string;
 			break;
 		case Opt_mountaddr:

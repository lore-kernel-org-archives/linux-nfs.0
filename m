From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 078/112] NFSv4: Add socket proto argument to setclientid
Date: Fri, 25 Jan 2008 11:37:51 -0500
Message-ID: <20080125163750.31887.4609.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756861AbYAYRAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:32 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lms010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:29 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c       |    4 +++-
 include/linux/nfs_xdr.h |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4e33cc7..92bfbcb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2891,10 +2891,12 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 
 	for(;;) {
 		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
-				sizeof(setclientid.sc_name), "%s/%s %s %u",
+				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
 				clp->cl_ipaddr,
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_ADDR),
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_PROTO),
 				cred->cr_ops->cr_name,
 				clp->cl_id_uniquifier);
 		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d8e395d..d342ae5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -666,7 +666,7 @@ struct nfs4_rename_res {
 	struct nfs_fattr *		new_fattr;
 };
 
-#define NFS4_SETCLIENTID_NAMELEN	(48)
+#define NFS4_SETCLIENTID_NAMELEN	(56)
 struct nfs4_setclientid {
 	const nfs4_verifier *		sc_verifier;
 	unsigned int			sc_name_len;

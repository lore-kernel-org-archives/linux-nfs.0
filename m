Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:49991 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbaCLQwB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:52:01 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so10849393iec.33
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:52:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] NFS: advertise only supported callback netids
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:51:47 -0400
Message-ID: <20140312165147.15349.49995.stgit@manet.1015granger.net>
In-Reply-To: <20140312164620.15349.22643.stgit@manet.1015granger.net>
References: <20140312164620.15349.22643.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 clients use the SETCLIENTID operation to inform NFS servers
how to contact a client's callback service.  If a server cannot
contact a client's callback service, that server will not delegate
to that client, which results in a performance loss.

Our client advertises "rdma" as the callback netid when the forward
channel is "rdma".  But our client always starts only "tcp" and
"tcp6" callback services.

Instead of advertising the forward channel netid, advertise "tcp"
or "tcp6" as the callback netid, based on the value of the
clientaddr mount option, since those are what our client currently
supports.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=69171
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b8..09dd967 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4883,6 +4883,20 @@ nfs4_init_uniform_client_string(const struct nfs_client *clp,
 				nodename);
 }
 
+/*
+ * nfs4_callback_up_net() starts only "tcp" and "tcp6" callback
+ * services.  Advertise one based on the address family of the
+ * clientaddr.
+ */
+static unsigned int
+nfs4_init_callback_netid(const struct nfs_client *clp, char *buf, size_t len)
+{
+	if (strchr(clp->cl_ipaddr, ':') != NULL)
+		return scnprintf(buf, len, "tcp6");
+	else
+		return scnprintf(buf, len, "tcp");
+}
+
 /**
  * nfs4_proc_setclientid - Negotiate client ID
  * @clp: state data structure
@@ -4924,12 +4938,10 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 						setclientid.sc_name,
 						sizeof(setclientid.sc_name));
 	/* cb_client4 */
-	rcu_read_lock();
-	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
-				sizeof(setclientid.sc_netid), "%s",
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_NETID));
-	rcu_read_unlock();
+	setclientid.sc_netid_len =
+				nfs4_init_callback_netid(clp,
+						setclientid.sc_netid,
+						sizeof(setclientid.sc_netid));
 	setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 23/29] NFS: Adjust nfs_clone_mount structure to store
	"struct	sockaddr *"
Date: Thu, 29 Nov 2007 14:41:56 -0500
Message-ID: <20071129194156.4170.88033.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHu-0001mX-6i
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:06 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHy-0002zu-2H
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:12 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Change the addr field in the nfs_clone_mount structure to store a "struct
sockaddr *" to support non-IPv4 addresses in the NFS client.

Note this is mostly a cosmetic change, and does not actually allow
referrals using IPv6 addresses.  The existing referral code assumes that
the server returns a string that represents an IPv4 address.  This code
needs to support hostnames and IPv6 addresses as well as IPv4 addresses,
thus it will need to be restructured in order to handle DNS resolution in
user space.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c        |    2 +-
 fs/nfs/internal.h      |    2 +-
 fs/nfs/nfs4namespace.c |   11 ++++++-----
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 346e4ca..e83d4cd 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1075,7 +1075,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname, (void *)data->addr,
+	error = nfs4_set_client(server, data->hostname, data->addr,
 			parent_client->cl_ipaddr,
 			data->authflavor,
 			parent_server->client->cl_xprt->prot,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b96364..58c3a2a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -21,7 +21,7 @@ struct nfs_clone_mount {
 	struct nfs_fattr *fattr;
 	char *hostname;
 	char *mnt_path;
-	struct sockaddr_in *addr;
+	struct sockaddr *addr;
 	rpc_authflavor_t authflavor;
 };
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index bd1b161..65dcbfd 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -172,7 +172,10 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 
 		s = 0;
 		while (s < location->nservers) {
-			struct sockaddr_in addr = {};
+			struct sockaddr_in addr = {
+				.sin_family	= AF_INET,
+				.sin_port	= htons(NFS_PORT),
+			};
 
 			if (location->servers[s].len <= 0 ||
 			    valid_ipaddr4(location->servers[s].data) < 0) {
@@ -181,10 +184,8 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 			}
 
 			mountdata.hostname = location->servers[s].data;
-			addr.sin_addr.s_addr = in_aton(mountdata.hostname);
-			addr.sin_family = AF_INET;
-			addr.sin_port = htons(NFS_PORT);
-			mountdata.addr = &addr;
+			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
+			mountdata.addr = (struct sockaddr *)&addr;
 
 			snprintf(page, PAGE_SIZE, "%s:%s",
 					mountdata.hostname,


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


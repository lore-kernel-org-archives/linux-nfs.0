From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/30] NFS: SETCLIENTID truncates client ID and netid
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221954.20945.76616.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756146AbYJGWcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:50 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The sc_name field is currently 56 bytes long.  This is not large enough
to hold a pair of IPv6 addresses, the authentication type, the protocol
name, and a uniquifier number.  The maximum possible size of the name
string using IPv6 addresses is just under 110 bytes, so I increased the
size of the sc_name field to accomodate this maximum.

In addition, the strings in the nfs4_setclientid structure are
constructed with scnprintf(), which wants to terminate its output with
'\0'.  The sc_netid field was large enough only for a three byte netid
string and a '\0' so inet6 netids were being truncated.  Perhaps we
don't need the overhead of scnprintf() to do a simple string copy, but
I fixed this by increasing the size of the buffer by one byte.

Since all three of the string buffers in nfs4_setclientid are
constructed with scnprintf(), I increased the size of all three by one
byte to document the requirement, although I don't think either the
universal address field or the name field will be so small that these
strings get truncated in this way.

The size of the Linux client's client ID on the wire will be larger
than before.  RFC 3530 suggests the size limit for client IDs is 1024,
and we are still well below that.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/nfs_xdr.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9cabbb3..f6e95bf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -672,16 +672,16 @@ struct nfs4_rename_res {
 	struct nfs_fattr *		new_fattr;
 };
 
-#define NFS4_SETCLIENTID_NAMELEN	(56)
+#define NFS4_SETCLIENTID_NAMELEN	(128)
 struct nfs4_setclientid {
 	const nfs4_verifier *		sc_verifier;
 	unsigned int			sc_name_len;
-	char				sc_name[NFS4_SETCLIENTID_NAMELEN];
+	char				sc_name[NFS4_SETCLIENTID_NAMELEN + 1];
 	u32				sc_prog;
 	unsigned int			sc_netid_len;
-	char				sc_netid[RPCBIND_MAXNETIDLEN];
+	char				sc_netid[RPCBIND_MAXNETIDLEN + 1];
 	unsigned int			sc_uaddr_len;
-	char				sc_uaddr[RPCBIND_MAXUADDRLEN];
+	char				sc_uaddr[RPCBIND_MAXUADDRLEN + 1];
 	u32				sc_cb_ident;
 };
 


From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 25/30] NFS: SETCLIENTID truncates client ID and netid
Date: Wed, 08 Oct 2008 13:56:29 -0400
Message-ID: <1223488589.7361.31.camel@localhost>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
	 <20081007221954.20945.76616.stgit@localhost.localdomain>
	 <09A58E7C-FC68-47C7-9C65-1BBDF255AF26@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10863 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753170AbYJHR4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:56:55 -0400
In-Reply-To: <09A58E7C-FC68-47C7-9C65-1BBDF255AF26@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-08 at 10:55 -0400, Chuck Lever wrote:
> Just a note...
> 
> Peter Staubach (I think) suggested NFS4_SETCLIENTID_NAMELEN should be  
> a slightly smaller value to prevent the compiler from adding wasted  
> space in the structure to align these fields.
> 
> If nothing else, you can safely make NFS4_SETCLIENTID_NAMELEN 127  
> instead of 128.

Done...
---------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 8 Oct 2008 13:54:52 -0400
NFS: Save padding bytes in struct nfs4_setclientid

Peter Staubach suggested reducing NFS4_SETCLIENTID_NAMELEN by one byte so
as to avoid 7 bytes of unnecessary padding.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/nfs_xdr.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f6e95bf..6ee6ae3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -672,7 +672,7 @@ struct nfs4_rename_res {
 	struct nfs_fattr *		new_fattr;
 };
 
-#define NFS4_SETCLIENTID_NAMELEN	(128)
+#define NFS4_SETCLIENTID_NAMELEN	(127)
 struct nfs4_setclientid {
 	const nfs4_verifier *		sc_verifier;
 	unsigned int			sc_name_len;


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:39899 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbaAXS46 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 13:56:58 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 24 Jan 2014 13:56:58 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id A5ABFC90049
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 13:56:52 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0OIutbH9634210
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 18:56:55 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0OIusX9016413
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 13:56:54 -0500
Date: Fri, 24 Jan 2014 12:56:52 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: handle servers that support only ALLOW ACE type.
Message-ID: <20140124185652.GA15292@us.ibm.com>
References: <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
 <1390583975-8914-1-git-send-email-malahal@us.ibm.com>
 <1390586285.2927.16.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
In-Reply-To: <1390586285.2927.16.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Trond Myklebust [trondmy@gmail.com] wrote:
> On Fri, 2014-01-24 at 11:19 -0600, Malahal Naineni wrote:
> > Currently we support ACLs if the NFS server file system supports both
> > ALLOW and DENY ACE types. This patch makes the Linux client work with
> > ACLs even if the server supports only 'ALLOW' ACE type.
> > 
> > Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> > ---
> >  fs/nfs/nfs4proc.c | 5 ++---
> >  1 file changed, 2 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 15052b8..e3b8fa6 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -4321,9 +4321,8 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
> >  
> >  static inline int nfs4_server_supports_acls(struct nfs_server *server)
> >  {
> > -	return (server->caps & NFS_CAP_ACLS)
> > -		&& (server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
> > -		&& (server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
> > +	return server->caps & NFS_CAP_ACLS &&
> > +		server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL;
> >  }
> >  
> >  /* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that
> 
> Wait... Having looked at the code a bit more carefully. Is there any
> reason to set NFS_CAP_ACLS at all if we don't see server->acl_bitmask &
> ACL4_SUPPORT_ALLOW_ACL?

I don't see any. Something like the attached patch should work!

Regards, Malahal.

--Qxx1br4bt0+wmkIi
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-nfs-handle-servers-that-support-only-ALLOW-ACE-type.patch"

>From 7b949e7906d40704c4ae28a06f4c501161cb5a99 Mon Sep 17 00:00:00 2001
From: Malahal Naineni <malahal@us.ibm.com>
Date: Thu, 23 Jan 2014 08:54:55 -0600
Subject: [PATCH] nfs: handle servers that support only ALLOW ACE type.

Currently we support ACLs if the NFS server file system supports both
ALLOW and DENY ACE types. This patch makes the Linux client work with
ACLs even if the server supports only 'ALLOW' ACE type.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4proc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b8..b007559 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2744,7 +2744,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 				NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
 				NFS_CAP_CTIME|NFS_CAP_MTIME|
 				NFS_CAP_SECURITY_LABEL);
-		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
+		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
+				res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
 			server->caps |= NFS_CAP_ACLS;
 		if (res.has_links != 0)
 			server->caps |= NFS_CAP_HARDLINKS;
@@ -4321,9 +4322,7 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 
 static inline int nfs4_server_supports_acls(struct nfs_server *server)
 {
-	return (server->caps & NFS_CAP_ACLS)
-		&& (server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
-		&& (server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
+	return server->caps & NFS_CAP_ACLS;
 }
 
 /* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that
-- 
1.8.3.1


--Qxx1br4bt0+wmkIi--


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34046 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750971AbdFBPVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Jun 2017 11:21:35 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4.2: Don't send mode again in post-EXCLUSIVE4_1 SETATTR with umask
Date: Fri,  2 Jun 2017 11:21:34 -0400
Message-Id: <fbdc189fe25652db84ec33f1e3f32b8f3cd83cc2.1496413498.git.bcodding@redhat.com>
In-Reply-To: <117d6500cc64c89ea56d8d4f940f14f7ecc744bb.1496411640.git.bcodding@redhat.com>
References: <117d6500cc64c89ea56d8d4f940f14f7ecc744bb.1496411640.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benjamin Coddington <bcodding@godel.bcodding.lab>

On 2 Jun 2017, at 9:55, Benjamin Coddington wrote:

> From: Benjamin Coddington <bcodding@godel.bcodding.lab>
>
> Now that we have umask support, we shouldn't re-send the mode in a SETATTR
> following an exclusive CREATE, or we risk having the same problem fixed in
> commit 5334c5bdac92 ("NFS: Send attributes in OPEN request for
> NFS4_CREATE_EXCLUSIVE4_1"), which is that files with S_ISGID will have that
> bit stripped away.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c08c46a3b8cd..403787319446 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2589,7 +2589,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
>
>   /* Except MODE, it seems harmless of setting twice. */
>   if (opendata->o_arg.createmode != NFS4_CREATE_EXCLUSIVE &&
> -     attrset[1] & FATTR4_WORD1_MODE)
> +     (attrset[1] & FATTR4_WORD1_MODE) ||
> +     (attrset[2] & FATTR4_WORD2_MODE_UMASK))

^^ I've definitely gotten the parens wrong here.. Here's the correction:
8<-----------------------------------------------------------------------

Now that we have umask support, we shouldn't re-send the mode in a SETATTR
following an exclusive CREATE, or we risk having the same problem fixed in
commit 5334c5bdac92 ("NFS: Send attributes in OPEN request for
NFS4_CREATE_EXCLUSIVE4_1"), which is that files with S_ISGID will have that
bit stripped away.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c08c46a3b8cd..4e43fd1270c4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2589,7 +2589,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
 
 	/* Except MODE, it seems harmless of setting twice. */
 	if (opendata->o_arg.createmode != NFS4_CREATE_EXCLUSIVE &&
-		attrset[1] & FATTR4_WORD1_MODE)
+		(attrset[1] & FATTR4_WORD1_MODE ||
+		 attrset[2] & FATTR4_WORD2_MODE_UMASK))
 		sattr->ia_valid &= ~ATTR_MODE;
 
 	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
-- 
2.9.3


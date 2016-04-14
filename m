Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33828 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbcDNMhN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2016 08:37:13 -0400
Received: by mail-qg0-f44.google.com with SMTP id c6so61698499qga.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 05:37:13 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] sunrpc: allow generic_match to handle creds with NULL group_info ptr
Date: Thu, 14 Apr 2016 08:36:58 -0400
Message-Id: <1460637425-1580-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
References: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function seems to assume that the group_info is never NULL. If we
fix it not to assume that then we should be able to avoid allocating
group_info for flexfiles DS creds.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/auth_generic.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 41248b1820c7..0bb0d58f240b 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -151,7 +151,7 @@ static int
 generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 {
 	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
-	int i;
+	int i, gnum;
 
 	if (acred->machine_cred)
 		return machine_cred_match(acred, gcred, flags);
@@ -166,9 +166,12 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 		goto out_match;
 
 	/* Slow path... */
-	if (gcred->acred.group_info->ngroups != acred->group_info->ngroups)
+	i = acred->group_info ? acred->group_info->ngroups : 0;
+	gnum = gcred->acred.group_info ? gcred->acred.group_info->ngroups : 0;
+
+	if (gnum != i)
 		goto out_nomatch;
-	for (i = 0; i < gcred->acred.group_info->ngroups; i++) {
+	for (i = 0; i < gnum; i++) {
 		if (!gid_eq(GROUP_AT(gcred->acred.group_info, i),
 				GROUP_AT(acred->group_info, i)))
 			goto out_nomatch;
-- 
2.5.5


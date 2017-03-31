Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33204 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754898AbdCaUJK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 16:09:10 -0400
Date: Fri, 31 Mar 2017 16:09:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Jason Yan <yanaijie@huawei.com>, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, miaoxie@huawei.com,
        zhaohongjiang@huawei.com
Subject: Re: [PATCH] nfsd: make strdup_if_nonnull static
Message-ID: <20170331200909.GC8487@fieldses.org>
References: <1490259456-15858-1-git-send-email-yanaijie@huawei.com>
 <20170329215132.GC29934@fieldses.org>
 <874lyb5kc8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874lyb5kc8.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 30, 2017 at 05:50:47PM +1100, NeilBrown wrote:
> On Wed, Mar 29 2017, J. Bruce Fields wrote:
> 
> > Thanks, applying for 4.12.--b.
> 
> Ugh... does strdup_if_nonnull() actually help readability at all?
> kstrdup() already handles NULL fine, which is what the name seems to
> suggest is happening.
> I would think kstrdup_report_error() is a name that better reflects the
> function.
> 
> Or just discard it:

Yes, what was I thinking?  Just didn't read kstrdup(), I guess.
Applying as follows.

--b.

commit 3c14417a48da
Author: NeilBrown <neilb@suse.com>
Date:   Thu Mar 23 16:57:36 2017 +0800

    nfsd4: remove pointless strdup_if_nonnull
    
    kstrdup() already checks for NULL.
    
    (Brought to our attention by Jason Yann noticing (from sparse output)
    that it should have been declared static.)
    
    Reported-by: Jason Yan <yanaijie@huawei.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9ef50addddb..78ff82123a1a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1912,28 +1912,17 @@ static void copy_clid(struct nfs4_client *target, struct nfs4_client *source)
 	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
 }
 
-int strdup_if_nonnull(char **target, char *source)
-{
-	if (source) {
-		*target = kstrdup(source, GFP_KERNEL);
-		if (!*target)
-			return -ENOMEM;
-	} else
-		*target = NULL;
-	return 0;
-}
-
 static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 {
 	int ret;
 
-	ret = strdup_if_nonnull(&target->cr_principal, source->cr_principal);
-	if (ret)
-		return ret;
-	ret = strdup_if_nonnull(&target->cr_raw_principal,
-					source->cr_raw_principal);
-	if (ret)
-		return ret;
+	target->cr_principal = kstrdup(source->cr_principal, GFP_KERNEL);
+	target->cr_raw_principal = kstrdup(source->cr_raw_principal,
+								GFP_KERNEL);
+	if ((source->cr_principal && ! target->cr_principal) ||
+	    (source->cr_raw_principal && ! target->cr_raw_principal))
+		return -ENOMEM;
+
 	target->cr_flavor = source->cr_flavor;
 	target->cr_uid = source->cr_uid;
 	target->cr_gid = source->cr_gid;

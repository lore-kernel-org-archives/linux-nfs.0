Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35170 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab2FKPke (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 11:40:34 -0400
Received: by bkcji2 with SMTP id ji2so3658186bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jun 2012 08:40:33 -0700 (PDT)
Message-ID: <4FD6116D.4070604@tonian.com>
Date: Mon, 11 Jun 2012 18:40:29 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] Something very wrong with layout_recall of RETURN_FILE
References: <4FC6B29C.3030803@panasas.com> <4FD60A78.8060604@tonian.com> <4FD6101A.7060502@panasas.com>
In-Reply-To: <4FD6101A.7060502@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-06-11 18:34, Boaz Harrosh wrote:
> On 06/11/2012 06:10 PM, Benny Halevy wrote:
> 
>> This should be fixed regardless so that exofs is more tolerant to "phantom"
>> layout returns.
>>
> 
> 
> It's not a crash at exofs, it's a crash at nfsd do to reference miss-match.
> 
> 
> <>
> 
>> This wasn't the original intent for cl_has_file_layout.
>>
>> I agree the requirement changed when we added the cookie magic
>> and the reliance of exofs on the layout recall process to be
>> precise about detecting the no layout case.  So on one hand
>> the process needs to be more robust and on the other we can
>> lookup the exact region as you suggest below.
>>
> 
> 
> I have lots of code changes to this, which works very well, to
> my satisfaction. It fixes the above and many other problems
> and is also a cleanup and fixture additions.
> 
> I would have sent it, if I was not busy with clients bugs found
> which are more urgent. The code is there and is being heavily
> tested as we speak. (mainly the client code, the server code is
> very good)
> 
> It'll take a few more days to send all this, in. Needs SPLITMEs
> and cleanup. (Tell me if you want RFC level code which will be
> harder for review, before hand)
> 
>> Then, we should be able to get rid of the layout states list altogether.
>> (practically reverting "pnfsd: layout recall layout state")
>>
> 
> 
> I have not removed this. As you say it's by now dead code. I'll send in
> what I have and we can surgically revert that thing as well. It will
> all be in SQUASHMEs and we can later re-arrange the patches for this
> to naturally fall off the patchlist. (I intend to help a bit with this
> work, in the areas these touch)

Great.  Feel free to use/test the following patch...

>From 537ddc4c2d35c820a5c74b783b139dbc11a36531 Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@tonian.com>
Date: Mon, 11 Jun 2012 18:29:03 +0300
Subject: [PATCH] SQUAHSME: pnfsd: get rid of fi_layout_states list

---
 fs/nfsd/nfs4pnfsd.c |   15 ++-------------
 fs/nfsd/nfs4state.c |    1 -
 fs/nfsd/pnfsd.h     |    1 -
 fs/nfsd/state.h     |    1 -
 4 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 4ee26ff..a8e85e9 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -147,8 +147,7 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
  * Note: must be called under the state lock
  */
 static struct nfs4_layout_state *
-alloc_init_layout_state(struct nfs4_client *clp, struct nfs4_file *fp,
-			stateid_t *stateid)
+alloc_init_layout_state(struct nfs4_client *clp, stateid_t *stateid)
 {
 	struct nfs4_layout_state *new;

@@ -157,10 +156,6 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 		return new;
 	kref_init(&new->ls_ref);
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
-	INIT_LIST_HEAD(&new->ls_perfile);
-	spin_lock(&layout_lock);
-	list_add(&new->ls_perfile, &fp->fi_layout_states);
-	spin_unlock(&layout_lock);
 	new->ls_roc = false;
 	return new;
 }
@@ -178,11 +173,6 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 			container_of(kref, struct nfs4_layout_state, ls_ref);

 	nfsd4_unhash_stid(&ls->ls_stid);
-	if (!list_empty(&ls->ls_perfile)) {
-		spin_lock(&layout_lock);
-		list_del(&ls->ls_perfile);
-		spin_unlock(&layout_lock);
-	}
 	kfree(ls);
 }

@@ -233,7 +223,7 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 			goto out;
 		}

-		ls = alloc_init_layout_state(clp, fp, stateid);
+		ls = alloc_init_layout_state(clp, stateid);
 		if (!ls) {
 			status = nfserr_jukebox;
 			goto out;
@@ -344,7 +334,6 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 		__func__, lp, clp, fp, fp->fi_inode);

 	kmem_cache_free(pnfs_layout_slab, lp);
-	list_del_init(&ls->ls_perfile);
 	/* release references taken by init_layout */
 	put_layout_state(ls);
 	put_nfs4_file(fp);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index db64d8e..930babd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2385,7 +2385,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 #if defined(CONFIG_PNFSD)
 	INIT_LIST_HEAD(&fp->fi_layouts);
-	INIT_LIST_HEAD(&fp->fi_layout_states);
 	fp->fi_fsid.major = current_fh->fh_export->ex_fsid;
 	fp->fi_fsid.minor = 0;
 	fp->fi_fhlen = current_fh->fh_handle.fh_size;
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index df8595f..d2d7795 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -44,7 +44,6 @@
 struct nfs4_layout_state {
 	struct kref		ls_ref;
 	struct nfs4_stid	ls_stid;
-	struct list_head	ls_perfile;
 	bool			ls_roc;
 };

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index a23ee0b..94cbcd1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -405,7 +405,6 @@ struct nfs4_file {
 	bool			fi_had_conflict;
 #if defined(CONFIG_PNFSD)
 	struct list_head	fi_layouts;
-	struct list_head	fi_layout_states;
 	/* used by layoutget / layoutrecall */
 	struct nfs4_fsid	fi_fsid;
 	u32			fi_fhlen;
-- 
1.7.6.5


> 
>> Benny
>>
> 
> 
> Thanks
> Boaz
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

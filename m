Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:35802 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750729AbcLHFDr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 00:03:47 -0500
Subject: Re: Revalidate failure leads to unmount
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20161206061747.GN1555@ZenIV.linux.org.uk>
Date: Thu, 8 Dec 2016 00:01:55 -0500
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Message-Id: <A0B40A4F-8CB0-4E2F-9519-CDA966DCBEB5@linuxhacker.ru>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru> <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru> <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru> <20161206020059.GL1555@ZenIV.linux.org.uk> <02B48074-7E2E-4DB5-9A88-4FD4E37088FA@linuxhacker.ru> <20161206050254.GM1555@ZenIV.linux.org.uk> <D061B89E-EFC7-49F8-86C0-C60FDF269D3C@linuxhacker.ru> <20161206061747.GN1555@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 6, 2016, at 1:17 AM, Al Viro wrote:

> On Tue, Dec 06, 2016 at 12:45:11AM -0500, Oleg Drokin wrote:
> 
>> Well, certainly if d_splice_alias was working like that so that even non-directory
>> dentry would find an alias (not necessarily unhashed even) for that same inode and use that instead, that would make ll_splice_alias/ll_find_alias unnecessary.
>> 
>> We still retain the weird d_compare() that rejects otherwise perfectly valid aliases
>> if the lock guarding them is gone, triggering relookup (and necessiating the
>> above logic to pick up just rejected alias again now that we have the lock again).
> 
> Why not have ->d_revalidate() kick them, instead?  _IF_ we have a way to
> do unhash-and-trigger-lookup that way, do you really need those games with
> ->d_compare()?

Ok, so this does appear to work in mainline, but not in the well known vendor kernels,
where they still live in the past with d_invalidate returning non zero and
lookup_dcache() dutifuly ignoring the error code from revalidate.

Anyway, I can submit the patch doing away with ll_dcompare, but I still
need the kludge to always return 1 when revalidating mountpoints,
otherwise they would be constantly unmounted, I guess.

Is this something you'd like to carry along with the rest of (yet to be) patches
that only unmount stuff on lookup failure/different result as we discussed before,
or should I shoot this to Greg right away?

The patch pretty much amounts to this now:
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 0e45d8f..f532167 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -69,38 +69,6 @@ static void ll_release(struct dentry *de)
 	call_rcu(&lld->lld_rcu_head, free_dentry_data);
 }
 
-/* Compare if two dentries are the same.  Don't match if the existing dentry
- * is marked invalid.  Returns 1 if different, 0 if the same.
- *
- * This avoids a race where ll_lookup_it() instantiates a dentry, but we get
- * an AST before calling d_revalidate_it().  The dentry still exists (marked
- * INVALID) so d_lookup() matches it, but we have no lock on it (so
- * lock_match() fails) and we spin around real_lookup().
- */
-static int ll_dcompare(const struct dentry *dentry,
-		       unsigned int len, const char *str,
-		       const struct qstr *name)
-{
-	if (len != name->len)
-		return 1;
-
-	if (memcmp(str, name->name, len))
-		return 1;
-
-	CDEBUG(D_DENTRY, "found name %.*s(%p) flags %#x refc %d\n",
-	       name->len, name->name, dentry, dentry->d_flags,
-	       d_count(dentry));
-
-	/* mountpoint is always valid */
-	if (d_mountpoint((struct dentry *)dentry))
-		return 0;
-
-	if (d_lustre_invalid(dentry))
-		return 1;
-
-	return 0;
-}
-
 /**
  * Called when last reference to a dentry is dropped and dcache wants to know
  * whether or not it should cache it:
@@ -255,6 +223,15 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 {
 	struct inode *dir = d_inode(dentry->d_parent);
 
+	/* mountpoint is always valid */
+	if (d_mountpoint((struct dentry *)dentry))
+		return 1;
+
+	/* No lock? Bail out */
+	if (d_lustre_invalid(dentry))
+		return 0;
+
+
 	/* If this is intermediate component path lookup and we were able to get
 	 * to this dentry, then its lock has not been revoked and the
 	 * path component is valid.
@@ -303,5 +280,4 @@ const struct dentry_operations ll_d_ops = {
 	.d_revalidate = ll_revalidate_nd,
 	.d_release = ll_release,
 	.d_delete  = ll_ddelete,
-	.d_compare = ll_dcompare,
 };


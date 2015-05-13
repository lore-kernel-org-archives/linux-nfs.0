Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35473 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933410AbbEMMz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 08:55:56 -0400
Message-ID: <555349D3.1020903@gmail.com>
Date: Wed, 13 May 2015 20:55:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
References: <554A149B.5060102@gmail.com>	<554A154B.6040103@gmail.com>	<20150508144031.6f0d3cda@notabene.brown>	<20150508134744.GA23753@fieldses.org>	<5550A9DF.1070908@gmail.com> <20150513142515.6bd881c8@notabene.brown> <555343CA.6010307@gmail.com>
In-Reply-To: <555343CA.6010307@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/13/2015 8:30 PM, Kinglong Mee wrote:
> On 5/13/2015 12:25 PM, NeilBrown wrote:
>> On Mon, 11 May 2015 21:08:47 +0800 Kinglong Mee <kinglongmee@gmail.com> wrote:
>>
>>> On 5/8/2015 9:47 PM, J. Bruce Fields wrote:
>>>> On Fri, May 08, 2015 at 02:40:31PM +1000, NeilBrown wrote:
>>>>> Thanks for this patch.  It looks good!
>>>>>
>>>>> My only comment on the code is that I would really like to see a
>>>>> "path_get_pin()" and "path_put_unpin()" rather than open coding:
>>>>>
>>>>>> +	dget(item->ek_path.dentry);
>>>>>> +	pin_insert_group(&new->ek_pin, item->ek_path.mnt, NULL);
>>>>>
>>>>> and 
>>>>>
>>>>>> +		dput(key->ek_path.dentry);
>>>>>> +		pin_remove(&key->ek_pin);
>>>>>
>>>>>
>>>>> But the question you raise is an important one:  Exactly which filesystems
>>>>> should be allowed to be unmounted?
>>>>> This is a change in behaviour - is it one that people uniformly would want?
>>>>>
>>>>> The kernel doesn't currently know which file systems were explicitly listed
>>>>> in /etc/exports, and which were found by following a 'crossmnt'.
>>>>> It could guess and allow the unmounting of anything below a 'crossmnt', but I
>>>>> wouldn't be comfortable with that - it is error prone.
>>>>>
>>>>> mountd does know what is in /etc/exports, and could tell the kernel.
>>>>> For the expkey cache, we could always use path_get_pin.
>>>>> For the export cache (where flags are available) we could use path_get
>>>>> or path_get_pin depending on some new flag.
>>>>>
>>>>> I'm not really sure it is worth it.  I would rather the filesystems could
>>>>> always be unmounted.  But doing that could possibly break someone's work
>>>>> flow.  Maybe.
>>>>>
>>>>> Or maybe I'm seeing problems where there aren't any.
>>>>>
>>>>> Anyone else have an opinion?
>>>>
>>>> The undisputed bug here was negative cache entries preventing unmount.
>>>> So most conservative might be just to purge negative entries.
>>>
>>> I'd like this,
>>> if the cache is valid, user should not be allowed to umount the filesystem.
>>>
>>>>
>>>> Otherwise, the only guarantees I think we've really had is that we won't
>>>> allow unmount if you hold any actual state on the filesystem (NLM locks,
>>>> NFSv4 locks, opens, or delegations).
>>>
>>> Those resources hold the reference of vfsmnt.
>>>
>>>>
>>>> If a filesystem is exported but no clients hold state on it, then it's
>>>> currently mostly chance whether the unmount succeeds or not.  So we're
>>>> probably free to change the behavior in this case.  I'd be inclined to
>>>> allow the unmount, but haven't thought this through carefully.
>>>
>>> If client mount a nfsserver succeed without holds state, 
>>> nfs server umounts the exported filesystem, 
>>> client also think the filesystem is valid, but it is umounted.
>>
>> This is no different from "exportfs -au" being run on the server, thus
>> unexporting the filesystem and making in unavailable to the client, even
>> though the client has it mounted.
> 
> No, I don't think so.
> If user using "exportfs -au" to flush caches, I think he known
> what the influence of he does, but an umount of filesystem, 
> maybe he doesn't known that contains flushing nfsd's exports cache.
> 
> For an using of nfsd exports, I'd like an error of an umount,
> because I don't realize the exports for nfsd.
> 
> I also think nfsd should allowing umount of unexported filesystem,
> because user has the right to umount it.

The following is a diff draft of umounting an unexported filesystem.

thanks,
Kinglong Mee

------------------------------------------------------------------------
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f79521a..bcaa914 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -309,11 +309,17 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
 static void svc_export_put(struct kref *ref)
 {
 	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
-	path_put(&exp->ex_path);
+
+	if (exp->ex_pin.kill) {
+		dput(exp->ex_path.dentry);
+		pin_remove(&exp->ex_pin);
+	} else
+		path_put(&exp->ex_path);
+
 	auth_domain_put(exp->ex_client);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	kfree(exp->ex_uuid);
-	kfree(exp);
+	kfree_rcu(exp, rcu_head);
 }
 
 static void svc_export_request(struct cache_detail *cd,
@@ -699,6 +705,7 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 	struct svc_export *new = container_of(cnew, struct svc_export, h);
 	struct svc_export *item = container_of(citem, struct svc_export, h);
 
+	init_fs_pin(&new->ex_pin, NULL);
 	kref_get(&item->ex_client->ref);
 	new->ex_client = item->ex_client;
 	new->ex_path = item->ex_path;
@@ -738,6 +745,24 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 	}
 }
 
+static void export_pin_kill(struct fs_pin *pin)
+{
+	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
+	cache_force_expire(exp->cd, &exp->h);
+}
+
+static void export_update_negative(struct cache_head *cnew, struct cache_head *citem)
+{
+	struct svc_export *new = container_of(cnew, struct svc_export, h);
+
+	if (!test_bit(CACHE_NEGATIVE, &new->h.flags))
+		return ;
+
+	init_fs_pin(&new->ex_pin, export_pin_kill);
+	pin_insert_group(&new->ex_pin, new->ex_path.mnt, NULL);
+	mntput(new->ex_path.mnt);
+}
+
 static struct cache_head *svc_export_alloc(void)
 {
 	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
@@ -758,6 +783,7 @@ static struct cache_detail svc_export_cache_template = {
 	.match		= svc_export_match,
 	.init		= svc_export_init,
 	.update		= export_update,
+	.update_negative= export_update_negative,
 	.alloc		= svc_export_alloc,
 };
 
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..c764a8e 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -4,6 +4,7 @@
 #ifndef NFSD_EXPORT_H
 #define NFSD_EXPORT_H
 
+#include <linux/fs_pin.h>
 #include <linux/sunrpc/cache.h>
 #include <uapi/linux/nfsd/export.h>
 
@@ -46,6 +47,8 @@ struct exp_flavor_info {
 
 struct svc_export {
 	struct cache_head	h;
+	struct cache_detail	*cd;
+
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct path		ex_path;
@@ -58,7 +61,9 @@ struct svc_export {
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
 	enum pnfs_layouttype	ex_layout_type;
 	struct nfsd4_deviceid_map *ex_devid_map;
-	struct cache_detail	*cd;
+
+	struct fs_pin		ex_pin;
+	struct rcu_head		rcu_head;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 437ddb6..39b31b5 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -101,6 +101,7 @@ struct cache_detail {
 	int			(*match)(struct cache_head *orig, struct cache_head *new);
 	void			(*init)(struct cache_head *orig, struct cache_head *new);
 	void			(*update)(struct cache_head *orig, struct cache_head *new);
+	void			(*update_negative)(struct cache_head *orig, struct cache_head *new);
 
 	/* fields below this comment are for internal use
 	 * and should not be touched by cache owners
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2928aff..4a95dee 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -149,9 +149,11 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	if (!test_bit(CACHE_VALID, &old->flags)) {
 		write_lock(&detail->hash_lock);
 		if (!test_bit(CACHE_VALID, &old->flags)) {
-			if (test_bit(CACHE_NEGATIVE, &new->flags))
+			if (test_bit(CACHE_NEGATIVE, &new->flags)) {
 				set_bit(CACHE_NEGATIVE, &old->flags);
-			else
+				if (detail->update_negative)
+					detail->update_negative(old, new);
+			} else
 				detail->update(old, new);
 			cache_fresh_locked(old, new->expiry_time);
 			write_unlock(&detail->hash_lock);
@@ -171,9 +173,11 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 	head = &detail->hash_table[hash];
 
 	write_lock(&detail->hash_lock);
-	if (test_bit(CACHE_NEGATIVE, &new->flags))
+	if (test_bit(CACHE_NEGATIVE, &new->flags)) {
 		set_bit(CACHE_NEGATIVE, &tmp->flags);
-	else
+		if (detail->update_negative)
+			detail->update_negative(old, new);
+	} else
 		detail->update(tmp, new);
 	tmp->next = *head;
 	*head = tmp;


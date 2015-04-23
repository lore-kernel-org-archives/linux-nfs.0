Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33777 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965609AbbDWMw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 08:52:56 -0400
Received: by pdbnk13 with SMTP id nk13so17801038pdb.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 05:52:56 -0700 (PDT)
Message-ID: <5538EB18.7080802@gmail.com>
Date: Thu, 23 Apr 2015 20:52:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
References: <553663B7.7030506@gmail.com>	<20150421215417.GE13782@fieldses.org>	<553781E2.1000900@gmail.com>	<20150422150703.GA1247@fieldses.org> <20150423094431.1a8aa68b@notabene.brown>
In-Reply-To: <20150423094431.1a8aa68b@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/23/2015 7:44 AM, NeilBrown wrote:
> On Wed, 22 Apr 2015 11:07:03 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
>>> Reference of dentry/mnt is like a cache, avoids re-finding of them,
>>> it is necessary to store them in svc_export.
>>>
>>> Neil points out another way of 'fs_pin', I will check that.
>>
>> Yes, that'd be interesting.  On a very quick look--I don't understand
>> what it's meant to do at all.  But if it does provide a way to get a
>> callback on umount, that'd certainly be interesting....
> 
> Yeah, on a quick look it isn't really obvious at all.
> 
> But I didn't read the code.  I read
>  https://lwn.net/Articles/636730/
> 
> which says:
> 
>     In its place is a mechanism by which an object can be added to a vfsmount
>     structure (which represents a mounted filesystem); that object supports 
>     only one method: kill(). These "pin" objects hang around until the final
>     reference to the vfsmount goes away, at which point each one's kill() function
>     is called. It thus is a clean mechanism for performing cleanup when a filesystem
>     goes away.
> 
> This is used to close "BSD process accounting" files on umount, and sound
> like the perfect interface for flushing things from the sunrpc cache on
> umount.

I have review those codes in fs/fs_pin.c and kernel/acct.c.
'fs_pin' is used to fix the race between file->f_path.mnt for acct
and umount, file->f_path.mnt just holds the reference of vfsmount
but not keep busy, umount will check the reference and return busy.

The logical is same as sunrpc cache for exports.

Before commit 3064c3563b ("death to mnt_pinned"), acct uses a hack
method, acct get a pin to vfsmount and then put the reference,
so umount finds no other reference and callback those pins in vfsmount,
at last umount success.

After that commit, besides pin to original vfsmount and put the reference
of the original vfsmount, acct clone the vfsmount storing in file->f_path.mnt.

The different between those two methods is the value of file->f_path.mnt,
the first one, it contains the original vfsmnt without reference,
the second one, contains a cloned vfsmnt with reference.

I have test the first method, pins to vfsmount for all exports cache,
nfsd can work but sometimes will delay or hang at rpc.mountd's calling
of name_to_handle_at, I can't find the reason.

Also test the second method, there are many problem caused by the cloned
vfsmount, mnt_clone_internal() change mnt_root values to the path dentry.

Those cases are tested for all exports cache, but, I think nfsd should
put the reference of vfsmount when finding exports upcall fail.
The success exports cache should also take it.

The following is a draft of the first method.

thanks,
Kinglong Mee

----------------------------------------------------------------------
diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index 611b540..553e8b1 100644
--- a/fs/fs_pin.c
+++ b/fs/fs_pin.c
@@ -17,6 +17,7 @@ void pin_remove(struct fs_pin *pin)
 	wake_up_locked(&pin->wait);
 	spin_unlock_irq(&pin->wait.lock);
 }
+EXPORT_SYMBOL(pin_remove);
 
 void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head *p)
 {
@@ -26,11 +27,13 @@ void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head
 	hlist_add_head(&pin->m_list, &real_mount(m)->mnt_pins);
 	spin_unlock(&pin_lock);
 }
+EXPORT_SYMBOL(pin_insert_group);
 
 void pin_insert(struct fs_pin *pin, struct vfsmount *m)
 {
 	pin_insert_group(pin, m, &m->mnt_sb->s_pins);
 }
+EXPORT_SYMBOL(pin_insert);
 
 void pin_kill(struct fs_pin *p)
 {
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c3e3b6e..3e3df8c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -309,7 +309,7 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
 static void svc_export_put(struct kref *ref)
 {
 	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
-	path_put(&exp->ex_path);
+	pin_remove(&exp->ex_pin);
 	auth_domain_put(exp->ex_client);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	kfree(exp->ex_uuid);
@@ -695,15 +695,26 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
 		orig->ex_path.mnt == new->ex_path.mnt;
 }
 
+static void export_pin_kill(struct fs_pin *pin)
+{
+	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
+
+	write_lock(&exp->cd->hash_lock);
+	cache_mark_expired(&exp->h);
+	pin_remove(pin);
+	write_unlock(&exp->cd->hash_lock);
+}
+
 static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 {
 	struct svc_export *new = container_of(cnew, struct svc_export, h);
 	struct svc_export *item = container_of(citem, struct svc_export, h);
 
+	init_fs_pin(&new->ex_pin, export_pin_kill);
 	kref_get(&item->ex_client->ref);
 	new->ex_client = item->ex_client;
 	new->ex_path = item->ex_path;
-	path_get(&item->ex_path);
+	pin_insert_group(&new->ex_pin, new->ex_path.mnt, NULL);
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..718a27e 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -4,6 +4,7 @@
 #ifndef NFSD_EXPORT_H
 #define NFSD_EXPORT_H
 
+#include <linux/fs_pin.h>
 #include <linux/sunrpc/cache.h>
 #include <uapi/linux/nfsd/export.h>
 
@@ -49,6 +50,7 @@ struct svc_export {
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct path		ex_path;
+	struct fs_pin		ex_pin;
 	kuid_t			ex_anon_uid;
 	kgid_t			ex_anon_gid;
 	int			ex_fsid;
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 437ddb6..6936684 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -206,6 +206,11 @@ static inline int cache_is_expired(struct cache_detail *detail, struct cache_hea
 		(detail->flush_time > h->last_refresh);
 }
 
+static inline void cache_mark_expired(struct cache_head *h)
+{
+	h->expiry_time = seconds_since_boot() - 1;
+}
+
 extern int cache_check(struct cache_detail *detail,
 		       struct cache_head *h, struct cache_req *rqstp);
 extern void cache_flush(void);


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36317 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbGBPSJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 11:18:09 -0400
Message-ID: <55955624.80503@gmail.com>
Date: Thu, 02 Jul 2015 23:17:56 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 10/10 v6] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
References: <558C0D6A.9050104@gmail.com> <558C121A.3020109@gmail.com> <20150701054751.GB17109@ZenIV.linux.org.uk>
In-Reply-To: <20150701054751.GB17109@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/1/2015 13:47, Al Viro wrote:
> On Thu, Jun 25, 2015 at 10:37:14PM +0800, Kinglong Mee wrote:
>> +static void expkey_validate(struct cache_head *h)
>> +{
>> +	struct svc_expkey *key = container_of(h, struct svc_expkey, h);
>> +
>> +	if (!test_bit(CACHE_VALID, &key->h.flags) ||
>> +	    test_bit(CACHE_NEGATIVE, &key->h.flags))
>> +		return;
>> +
>> +	if (atomic_read(&h->ref.refcount) == 1) {
>> +		mutex_lock(&key->ek_mutex);
> 
> ... followed by kref_get(&h->ref) in caller

Got it.

> 
>> +	if (atomic_read(&h->ref.refcount) == 2) {
>> +		mutex_lock(&key->ek_mutex);
> 
> ... followed by kref_put() in caller.

No, must before kref_put.
If kref_put() to zero will free the structure.

> 
> Suppose two threads call cache_get() at the same time.  Refcount is 1.
> Depending on the timing you get either one or both grabbing vfsmount
> references.  Whichever variant matches the one you want, there is no way
> to tell one from another afterwards and they *do* differ in the resulting
> vfsmount refcount changes.
> 
> Similar to that, suppose the refcount is 3 and two threads call cache_put()
> at the same time.  If one of them gets through the entire thing (including
> kref_put()) before the other gets to atomic_read(), you get the second
> see refcount 2 and do that mntput().  If not, _nobody_ will ever see refcount
> 2 and mntput() is not done.
> 
> How can that code possibly be correct?  This kind of splitting atomic_read
> from increment/decrement (and slapping a sleeping operation in between,
> no less) is basically never right.  Not unless you have everything serialized
> on the outside and do not need the atomic in the first place, which doesn't
> seem to be the case here.

For protect the reference, maybe I will implements a couple of get_ref/put_ref
as kref_get/kref_put.

+static void expkey_get_ref(struct cache_head *h)
+{
+       struct svc_expkey *key = container_of(h, struct svc_expkey, h);
+
+       mutex_lock(&key->ref_mutex);
+       kref_get(&h->ref);
+
+       if (!test_bit(CACHE_VALID, &key->h.flags) ||
+           test_bit(CACHE_NEGATIVE, &key->h.flags))
+               goto out;
+
+       if (atomic_read(&h->ref.refcount) == 2) {
+               if (legitimize_mntget(key->ek_path.mnt) == NULL) {
+                       printk(KERN_WARNING "%s: Get mnt for %pd2 failed!\n",
+                               __func__, key->ek_path.dentry);
+                       set_bit(CACHE_NEGATIVE, &h->flags);
+               } else
+                       key->ek_mnt_ref = true;
+       }
+out:
+       mutex_unlock(&key->ref_mutex);
+}
+
+static void expkey_put_ref(struct cache_head *h)
+{
+       struct svc_expkey *key = container_of(h, struct svc_expkey, h);
+
+       mutex_lock(&key->ref_mutex);
+       if (key->ek_mnt_ref && (atomic_read(&h->ref.refcount) == 2)) {
+               mntput(key->ek_path.mnt);
+               key->ek_mnt_ref = false;
+       }
+
+       if (unlikely(!atomic_dec_and_test(&h->ref.refcount))) {
+               mutex_unlock(&key->ref_mutex);
+               return ;
+       }
+
+       expkey_put(&h->ref);
+}
+

Code for nfsd exports cache is similar as expkey.

thanks,
Kinglong Mee

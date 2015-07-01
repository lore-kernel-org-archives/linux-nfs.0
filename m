Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42444 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbGAFry (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jul 2015 01:47:54 -0400
Date: Wed, 1 Jul 2015 06:47:51 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v6] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150701054751.GB17109@ZenIV.linux.org.uk>
References: <558C0D6A.9050104@gmail.com>
 <558C121A.3020109@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <558C121A.3020109@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 25, 2015 at 10:37:14PM +0800, Kinglong Mee wrote:
> +static void expkey_validate(struct cache_head *h)
> +{
> +	struct svc_expkey *key = container_of(h, struct svc_expkey, h);
> +
> +	if (!test_bit(CACHE_VALID, &key->h.flags) ||
> +	    test_bit(CACHE_NEGATIVE, &key->h.flags))
> +		return;
> +
> +	if (atomic_read(&h->ref.refcount) == 1) {
> +		mutex_lock(&key->ek_mutex);

... followed by kref_get(&h->ref) in caller

> +	if (atomic_read(&h->ref.refcount) == 2) {
> +		mutex_lock(&key->ek_mutex);

... followed by kref_put() in caller.

Suppose two threads call cache_get() at the same time.  Refcount is 1.
Depending on the timing you get either one or both grabbing vfsmount
references.  Whichever variant matches the one you want, there is no way
to tell one from another afterwards and they *do* differ in the resulting
vfsmount refcount changes.

Similar to that, suppose the refcount is 3 and two threads call cache_put()
at the same time.  If one of them gets through the entire thing (including
kref_put()) before the other gets to atomic_read(), you get the second
see refcount 2 and do that mntput().  If not, _nobody_ will ever see refcount
2 and mntput() is not done.

How can that code possibly be correct?  This kind of splitting atomic_read
from increment/decrement (and slapping a sleeping operation in between,
no less) is basically never right.  Not unless you have everything serialized
on the outside and do not need the atomic in the first place, which doesn't
seem to be the case here.

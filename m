Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38471 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbbGODt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 23:49:59 -0400
Date: Wed, 15 Jul 2015 13:49:48 +1000
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150715134948.3ebd0a70@noble>
In-Reply-To: <20150713064353.GQ17109@ZenIV.linux.org.uk>
References: <55A11010.6050005@gmail.com>
 <55A111A8.2040701@gmail.com>
 <20150713133934.6a4ef77d@noble>
 <20150713142059.493a790e@noble>
 <20150713044553.GN17109@ZenIV.linux.org.uk>
 <20150713152133.571e0cb7@noble>
 <20150713160243.6173a214@noble>
 <20150713060802.GP17109@ZenIV.linux.org.uk>
 <20150713163201.0e5eaf23@noble>
 <20150713064353.GQ17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Jul 2015 07:43:53 +0100 Al Viro <viro@ZenIV.linux.org.uk>
wrote:

> On Mon, Jul 13, 2015 at 04:32:01PM +1000, NeilBrown wrote:
> > pin_remove() disconnects the pinning thing (sunrpc cache entry in this
> > case) from the pinned thing (vfsmnt in this case).
> > After it has run the pinned thing can do whatever it likes without any
> > reference to the pinning thing, and the pinning thing just needs to wait
> > an RCU grace period, and then can do whatever it likes.
> > 
> > The "cleanup" is, in this case, just a call to rcu_kfree().  There is
> > no need for umount(2) to wait for it.
> > 
> > 
> > Certainly any state that the pinning structure has that relates to the
> > pinned structure must be cleaned up before calling pin_remove, so for
> > example dput() must be called on path.dentry *before* pin_remove is
> > called on path.mnt.  But other parts of the pinning structure can be
> > handled as its owner chooses.
> 
> Then what's the difference between that and what's getting done in ->kill()
> triggered by cleanup_mnt()?

Uhm... probably nothing.  I'm not sure what you are getting at.
I just need to do it at a different time to cleanup_mnt(), but also to
be aware that doing it might race with clean_mnt().


> 
> In any case, you have two possibilities - explicit unexport triggering that
> dput(), etc. and umount(2) triggering the same.  Whoever comes second gets
> to wait until it's done.  So why not make the point where we commit to
> unexporting the sucker the place where we do pin_kill()?  And have ->kill()
> of that thing prevent appearance of new entries, then wait for them to run
> down.  Which is precisely the same thing you want to happen on umount...

The "wait for them to run down" part is the sticking point.  We don't
have any easy way to wait for there to be no more references, so I'd
really like to use the waiting that pin_kill() already does.

I want the ->kill function to just unhash the cache entry, and then
wait for pin_delete() to be called.

The final 'put' on the cache entry calls dput on the dentry and then
pin_remove().

The ->kill function can wait for that to happen by calling pin_kill().

I guess there is no real need for a return value from pin_remove().

So
  static void expkey_pin_kill(struct fs_pin *pin)
  {
     struct svc_expkey *key = container_of(pin, ....);

     cache_delete_entry(key->cd, &key->h);
     pin_kill(&key->ek_pin); /* recursive call will wait for
                              * pin_delete() to be called */
  }

and static void expkey_put(struct kref *ref)
    {
        struct svc_expkey *key = container_of(ref, ....); 

        auth_domain_put(key->ek_client);
        if (test_bit(CACHE_VALID, &key->h.flags) &&
            !test_bit(CACHE_NEGATIVE, &key->h.flags))
               path_put_unpin(&key->ek_path, &key->ek_pin);
        kfree_rcu(key, rcu_head):
    }

We ensure that no new references are taken by svc_expkey_lookup()
calling legitimize_mntget() and returning NULL if that fails.
It should probably call cache_delete_entry() when that happens just to
be on the safe side.
cache_delete_entry() must check if the object is still in the hash
table before deleting it.

So I think it can work nicely without any changes to the fs_pin code.

Can you see any further problems?

Thanks,
NeilBrown


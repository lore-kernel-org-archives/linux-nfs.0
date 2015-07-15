Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45324 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbbGOGv1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 02:51:27 -0400
Date: Wed, 15 Jul 2015 16:51:13 +1000
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150715165113.5e8b3fa2@noble>
In-Reply-To: <20150715045756.GS17109@ZenIV.linux.org.uk>
References: <55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150713142059.493a790e@noble>
	<20150713044553.GN17109@ZenIV.linux.org.uk>
	<20150713152133.571e0cb7@noble>
	<20150713160243.6173a214@noble>
	<20150713060802.GP17109@ZenIV.linux.org.uk>
	<20150713163201.0e5eaf23@noble>
	<20150713064353.GQ17109@ZenIV.linux.org.uk>
	<20150715134948.3ebd0a70@noble>
	<20150715045756.GS17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 15 Jul 2015 05:57:56 +0100 Al Viro <viro@ZenIV.linux.org.uk>
wrote:

> On Wed, Jul 15, 2015 at 01:49:48PM +1000, NeilBrown wrote:
> 
> > > In any case, you have two possibilities - explicit unexport triggering that
> > > dput(), etc. and umount(2) triggering the same.  Whoever comes second gets
> > > to wait until it's done.  So why not make the point where we commit to
> > > unexporting the sucker the place where we do pin_kill()?  And have ->kill()
> > > of that thing prevent appearance of new entries, then wait for them to run
> > > down.  Which is precisely the same thing you want to happen on umount...
> > 
> > The "wait for them to run down" part is the sticking point.  We don't
> > have any easy way to wait for there to be no more references, so I'd
> > really like to use the waiting that pin_kill() already does.
> 
> > I want the ->kill function to just unhash the cache entry, and then
> > wait for pin_delete() to be called.
> 
> pin_remove, presumably?

Presumably, yes.

> 
> > The final 'put' on the cache entry calls dput on the dentry and then
> > pin_remove().
> > 
> > The ->kill function can wait for that to happen by calling pin_kill().
> 
> > I guess there is no real need for a return value from pin_remove().
> > 
> > So
> >   static void expkey_pin_kill(struct fs_pin *pin)
> >   {
> >      struct svc_expkey *key = container_of(pin, ....);
> > 
> >      cache_delete_entry(key->cd, &key->h);
> 
> 
> ... and another CPU drops the last reference, freeing the sucker.

*That's* why I wanted pin_remove to return something.

Why didn't you like that option again?

To recap:
pin_remove does:

  tmp = pin->done;
  pin->done = 1;
  ...
  return tmp;

path_put_unpin() returns the return value of pin_remove()

expkey_put() does:
   auth_domain_put(key->ek_client);
   if (test some bits)
       if (path_put_unpin() < 0)
          /* pin_kill has taken over */
          return
   kfree_rcu(key, rcu_head);
}

and expkey_pin_kill() does:

   cache_delete_entry(key->cd, &key->h);
   pin_kill(&key->ek_pin);
   kfee_rcu(key, rcu_head);
}


Thanks,
NeilBrown


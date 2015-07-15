Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42454 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbbGOE6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 00:58:01 -0400
Date: Wed, 15 Jul 2015 05:57:56 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150715045756.GS17109@ZenIV.linux.org.uk>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150715134948.3ebd0a70@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 15, 2015 at 01:49:48PM +1000, NeilBrown wrote:

> > In any case, you have two possibilities - explicit unexport triggering that
> > dput(), etc. and umount(2) triggering the same.  Whoever comes second gets
> > to wait until it's done.  So why not make the point where we commit to
> > unexporting the sucker the place where we do pin_kill()?  And have ->kill()
> > of that thing prevent appearance of new entries, then wait for them to run
> > down.  Which is precisely the same thing you want to happen on umount...
> 
> The "wait for them to run down" part is the sticking point.  We don't
> have any easy way to wait for there to be no more references, so I'd
> really like to use the waiting that pin_kill() already does.

> I want the ->kill function to just unhash the cache entry, and then
> wait for pin_delete() to be called.

pin_remove, presumably?

> The final 'put' on the cache entry calls dput on the dentry and then
> pin_remove().
> 
> The ->kill function can wait for that to happen by calling pin_kill().

> I guess there is no real need for a return value from pin_remove().
> 
> So
>   static void expkey_pin_kill(struct fs_pin *pin)
>   {
>      struct svc_expkey *key = container_of(pin, ....);
> 
>      cache_delete_entry(key->cd, &key->h);


... and another CPU drops the last reference, freeing the sucker.

>      pin_kill(&key->ek_pin); /* recursive call will wait for
>                               * pin_delete() to be called */

... oopsing on the spot.

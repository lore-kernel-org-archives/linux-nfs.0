Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34907 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbcFLNNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2016 09:13:21 -0400
Received: by mail-yw0-f171.google.com with SMTP id z186so87164798ywd.2
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 06:13:20 -0700 (PDT)
Message-ID: <1465737197.8881.22.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: Close a race between access checking/setting in
 nfs4_get_vfs_file
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andrew W Elble <aweits@rit.edu>
Date: Sun, 12 Jun 2016 09:13:17 -0400
In-Reply-To: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
References: <1465406560.30890.10.camel@poochiereds.net>
	 <1465506099-475103-1-git-send-email-green@linuxhacker.ru>
	 <D672EBB0-E73C-4BA6-BB2C-F687CA780CBA@linuxhacker.ru>
	 <1465555833.1425.15.camel@poochiereds.net>
	 <20160610205545.GA13766@fieldses.org>
	 <B1897F84-EAAF-4AA4-921E-6FFD7FED0A9A@linuxhacker.ru>
	 <1465695219.9492.4.camel@poochiereds.net>
	 <EFD3D41C-1992-40CD-B736-13FDEC17F75E@linuxhacker.ru>
	 <1465699835.10915.22.camel@poochiereds.net>
	 <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-06-11 at 23:15 -0400, Oleg Drokin wrote:
> On Jun 11, 2016, at 10:50 PM, Jeff Layton wrote:
> 
> > 
> > On Sat, 2016-06-11 at 22:06 -0400, Oleg Drokin wrote:
> > > 
> > > 
> > > Hm. I am trying to lock the newly initialized one and that seems to be holding up
> > > well (but I want 24 hours just to be extra sure).
> > > Hn, I just noticed a bug in this, so that'll reset the clock back.
> > > 
> > > But I think we cannot return with locked one if we found existing one due to lock
> > > inversion?
> > > I see that normally first we lock the state rwsem (now mutex) and then
> > > lock the fi_lock.
> > > Now if we make init_open_stateid() to lock the new state mutex while the fi_lock
> > > is locked - that's probably ok, because we can do it before adding it to the list,
> > > so nobody can find it.
> > > Now the existing state that we find, we cannot really lock while holding that fi_lock,
> > > because what if there's a parallel thread that already holds the mutex and now
> > > wants the fi_lock?
> > > And so it's probably best to return with existing state unlocked and let caller lock it?
> > > Or do you think it's best to separately lock the found stp outside of spinlock
> > > just for consistency?
> > I think we just have to ensure that if the new stateid is hashed that
> > its mutex is locked prior to being inserted into the hashtable. That
> > should prevent the race you mentioned.
> > 
> > If we find an existing one in the hashtable in init_open_stateid, then
> > we _can_ take the mutex after dropping the spinlocks, since we won't
> > call release_open_stateid in that case anyway.
> Yes.
> 
> > 
> > We'll also need to consider what happens if nfs4_get_vfs_file fails
> > after we hashed the stateid, but then another task finds it while
> > processing another open. So we might have to have release_open_stateid
> > unlock the mutex after unhashing the stateid, but before putting the
> > reference, and then have init_open_stateid check to see if the thing is
> > still hashed after it gets the mutex.
> Hm.
> So what's going to go wrong if another user reuses the unhashed stateid?
> As long as they drop it once they are done it'll be freed and all is fine, no?
> Are there other implications?
> Hm, it looks like free_ol_stateid_reaplist() just frees the thing without any looking
> into mutexes and stuff?
> 

The problem there is that you're sending a very soon to be defunct
stateid to the client as valid, which means the client will end up in
state recovery (at best).

The initial open is somewhat of a special case...we are hashing a new
stateid. If the operation that hashes it fails, then we want to make
like it never happened at all. The client will never see it, so we
don't want to leave it hanging around on the server. We need to unhash
the stateid in that case.

So, yes, the mutex doesn't really prevent the thing from being
unhashed, but if you take the mutex and the thing is still hashed
afterward, then you know that the above situation didn't happen. The
initial incarnation of the stateid will have been sent to the client.

> Ok, so we get the mutex, check that the stateid is hashed, it's not anymore
> (actually unhashing could be done without mutex too, right? so just mutex held
> is not going to protect us), then we need to drop the mutex and restart the search
> from scratch (including all relocking), I assume?

Yeah, that's what I was thinking. It should be a fairly rare race so
taking an extra hit on the locking in that case shouldn't be too bad. I
think there's quite a bit of opportunity to simplify the open path by
reworking this code as well.

What we probably need to do is turn nfsd4_find_existing_open into
something that intializes and hashes the stateid if it doesn't find one
, and returns it with the mutex locked. It could also do the check to
see if an existing stateid was still hashed after taking the mutex and
could redrive the search if it isn't. That would also make the open
code more resilient in the face of OPEN vs. CLOSE races, which would
also be nice...

> I guess I'll have it as a separate follow on patch.
> We'll probably also need some fault-injection here to trigger this case, as triggering
> it "naturally" will be a tough problem even on my mega-racy setup.
> 
> Something like:
>                 if (swapstp) {
> …
> 		}
> 		if (FAULTINJECTION) {
> 			msleep(some_random_time);
> 			status = nfserr_eio;
> 		} else
> 			status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open); 
> 
> should increase the chance.

Sure. Look for CONFIG_NFSD_FAULT_INJECTION. You might be able to use
that framework (though it is a bit manky).

> Ideally there'd be a way to trigger this case more deterministically,
> how do I have two OPEN requests in parallel in NFS for the same file,
> just have two threads do it and that would 100% result in two requests,
> no merging anywhere along the way that I need to be aware of?

Yeah, that's basically it. You need two racing OPEN calls for the same
stateid. Might be easiest to do with something like pynfs...

-- 
Jeff Layton <jlayton@poochiereds.net>

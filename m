Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:36528 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767AbcFLDPw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jun 2016 23:15:52 -0400
Subject: Re: [PATCH] nfsd: Close a race between access checking/setting in nfs4_get_vfs_file
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465699835.10915.22.camel@poochiereds.net>
Date: Sat, 11 Jun 2016 23:15:39 -0400
Cc: "J . Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andrew W Elble <aweits@rit.edu>
Message-Id: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
References: <1465406560.30890.10.camel@poochiereds.net> <1465506099-475103-1-git-send-email-green@linuxhacker.ru> <D672EBB0-E73C-4BA6-BB2C-F687CA780CBA@linuxhacker.ru> <1465555833.1425.15.camel@poochiereds.net> <20160610205545.GA13766@fieldses.org> <B1897F84-EAAF-4AA4-921E-6FFD7FED0A9A@linuxhacker.ru> <1465695219.9492.4.camel@poochiereds.net> <EFD3D41C-1992-40CD-B736-13FDEC17F75E@linuxhacker.ru> <1465699835.10915.22.camel@poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 11, 2016, at 10:50 PM, Jeff Layton wrote:

> On Sat, 2016-06-11 at 22:06 -0400, Oleg Drokin wrote:
>> 
>> Hm. I am trying to lock the newly initialized one and that seems to be holding up
>> well (but I want 24 hours just to be extra sure).
>> Hn, I just noticed a bug in this, so that'll reset the clock back.
>> 
>> But I think we cannot return with locked one if we found existing one due to lock
>> inversion?
>> I see that normally first we lock the state rwsem (now mutex) and then
>> lock the fi_lock.
>> Now if we make init_open_stateid() to lock the new state mutex while the fi_lock
>> is locked - that's probably ok, because we can do it before adding it to the list,
>> so nobody can find it.
>> Now the existing state that we find, we cannot really lock while holding that fi_lock,
>> because what if there's a parallel thread that already holds the mutex and now
>> wants the fi_lock?
>> And so it's probably best to return with existing state unlocked and let caller lock it?
>> Or do you think it's best to separately lock the found stp outside of spinlock
>> just for consistency?
> 
> I think we just have to ensure that if the new stateid is hashed that
> its mutex is locked prior to being inserted into the hashtable. That
> should prevent the race you mentioned.
> 
> If we find an existing one in the hashtable in init_open_stateid, then
> we _can_ take the mutex after dropping the spinlocks, since we won't
> call release_open_stateid in that case anyway.

Yes.

> We'll also need to consider what happens if nfs4_get_vfs_file fails
> after we hashed the stateid, but then another task finds it while
> processing another open. So we might have to have release_open_stateid
> unlock the mutex after unhashing the stateid, but before putting the
> reference, and then have init_open_stateid check to see if the thing is
> still hashed after it gets the mutex.

Hm.
So what's going to go wrong if another user reuses the unhashed stateid?
As long as they drop it once they are done it'll be freed and all is fine, no?
Are there other implications?
Hm, it looks like free_ol_stateid_reaplist() just frees the thing without any looking
into mutexes and stuff?

Ok, so we get the mutex, check that the stateid is hashed, it's not anymore
(actually unhashing could be done without mutex too, right? so just mutex held
is not going to protect us), then we need to drop the mutex and restart the search
from scratch (including all relocking), I assume?
I guess I'll have it as a separate follow on patch.
We'll probably also need some fault-injection here to trigger this case, as triggering
it "naturally" will be a tough problem even on my mega-racy setup.

Something like:
                if (swapstp) {
…
		}
		if (FAULTINJECTION) {
			msleep(some_random_time);
			status = nfserr_eio;
		} else
			status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open); 

should increase the chance.
Ideally there'd be a way to trigger this case more deterministically,
how do I have two OPEN requests in parallel in NFS for the same file,
just have two threads do it and that would 100% result in two requests,
no merging anywhere along the way that I need to be aware of?
Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36501 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbcFNWw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 18:52:28 -0400
Received: by mail-yw0-f193.google.com with SMTP id w195so580703ywd.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 15:52:27 -0700 (PDT)
Message-ID: <1465944743.12291.4.camel@poochiereds.net>
Subject: Re: [PATCH v2] nfsd: Always lock state exclusively.
From: Jeff Layton <jlayton@poochiereds.net>
To: "J . Bruce Fields" <bfields@fieldses.org>,
        Oleg Drokin <green@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 14 Jun 2016 18:52:23 -0400
In-Reply-To: <20160614185032.GJ25973@fieldses.org>
References: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
	 <1465781187-824653-1-git-send-email-green@linuxhacker.ru>
	 <20160614153808.GD25973@fieldses.org>
	 <ED916555-2D4D-4BF5-8850-9A17D0ABFE82@linuxhacker.ru>
	 <20160614185032.GJ25973@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-06-14 at 14:50 -0400, J . Bruce Fields wrote:
> On Tue, Jun 14, 2016 at 11:53:27AM -0400, Oleg Drokin wrote:
> > 
> > 
> > On Jun 14, 2016, at 11:38 AM, J . Bruce Fields wrote:
> > 
> > > 
> > > On Sun, Jun 12, 2016 at 09:26:27PM -0400, Oleg Drokin wrote:
> > > > 
> > > > It used to be the case that state had an rwlock that was locked for write
> > > > by downgrades, but for read for upgrades (opens). Well, the problem is
> > > > if there are two competing opens for the same state, they step on
> > > > each other toes potentially leading to leaking file descriptors
> > > > from the state structure, since access mode is a bitmap only set once.
> > > > 
> > > > Extend the holding region around in nfsd4_process_open2() to avoid
> > > > racing entry into nfs4_get_vfs_file().
> > > > Make init_open_stateid() return with locked stateid to be unlocked
> > > > by the caller.
> > > > 
> > > > Now this version held up pretty well in my testing for 24 hours.
> > > > It still does not address the situation if during one of the racing
> > > > nfs4_get_vfs_file() calls we are getting an error from one (first?)
> > > > of them. This is to be addressed in a separate patch after having a
> > > > solid reproducer (potentially using some fault injection).
> > > > 
> > > > Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> > > > ---
> > > > fs/nfsd/nfs4state.c | 47 +++++++++++++++++++++++++++--------------------
> > > > fs/nfsd/state.h     |  2 +-
> > > > 2 files changed, 28 insertions(+), 21 deletions(-)
> > > > 
> > > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > > index f5f82e1..fa5fb5a 100644
> > > > --- a/fs/nfsd/nfs4state.c
> > > > +++ b/fs/nfsd/nfs4state.c
> > > > @@ -3487,6 +3487,10 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> > > > 	struct nfs4_openowner *oo = open->op_openowner;
> > > > 	struct nfs4_ol_stateid *retstp = NULL;
> > > > 
> > > > +	/* We are moving these outside of the spinlocks to avoid the warnings */
> > > > +	mutex_init(&stp->st_mutex);
> > > > +	mutex_lock(&stp->st_mutex);
> > > > +
> > > > 	spin_lock(&oo->oo_owner.so_client->cl_lock);
> > > > 	spin_lock(&fp->fi_lock);
> > > > 
> > > > @@ -3502,13 +3506,14 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> > > > 	stp->st_access_bmap = 0;
> > > > 	stp->st_deny_bmap = 0;
> > > > 	stp->st_openstp = NULL;
> > > > -	init_rwsem(&stp->st_rwsem);
> > > > 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> > > > 	list_add(&stp->st_perfile, &fp->fi_stateids);
> > > > 
> > > > out_unlock:
> > > > 	spin_unlock(&fp->fi_lock);
> > > > 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
> > > > +	if (retstp)
> > > > +		mutex_lock(&retstp->st_mutex);
> > > > 	return retstp;
> > > You're returning with both stp->st_mutex and retstp->st_mutex locked.
> > > Did you mean to drop that first lock in the (retstp) case, or am I
> > > missing something?
> > Well, I think it's ok (perhaps worthy of a comment) it's that if we matched a different
> > retstp state, then stp is not used and either released right away or even
> > if reused, it would be reinitialized in another call to init_open_stateid(),
> > so it's fine?
> Oh, I see, you're right.
> 
> Though I wouldn't have been surprised if that triggered some kind of
> warning--I guess it's OK here, but typically if I saw a structure freed
> that had a locked lock in it I'd be a little suspicious that somebody
> made a mistake.
> 
> --b.

I think I'd still prefer to have it unlock the mutex in the event that
it's not going to use it after all. While that kind of thing is ok for
now, it's stuff like that that can turn into a subtle source of bugs
later.

Also, I think I'd be more comfortable with this being split into (at
least) two patches. Do one patch as a straight conversion from rwsem to
mutex, and then another that changes the code to take the mutex before
hashing the new stateid.

-- 
Jeff Layton <jlayton@poochiereds.net>

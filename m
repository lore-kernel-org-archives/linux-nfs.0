Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:48659 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754580AbaHUOCL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 10:02:11 -0400
Received: by mail-qg0-f41.google.com with SMTP id z107so5428214qgd.14
        for <linux-nfs@vger.kernel.org>; Thu, 21 Aug 2014 07:02:10 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 21 Aug 2014 10:02:07 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Joe Perches <joe@perches.com>, eshel@almaden.ibm.com
Subject: Re: [PATCH] lockd: Remove unused b_fl member from struct nlm_block
Message-ID: <20140821100207.34066459@tlielax.poochiereds.net>
In-Reply-To: <53F5F12B.1020801@gmail.com>
References: <53F47357.7050608@gmail.com>
	<20140820065826.6def22d5@tlielax.poochiereds.net>
	<53F4904B.6080204@gmail.com>
	<20140820090412.309b7599@tlielax.poochiereds.net>
	<53F5F12B.1020801@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 21 Aug 2014 21:16:27 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> On 8/20/2014 21:04, Jeff Layton wrote:
> > On Wed, 20 Aug 2014 20:10:51 +0800
> > Kinglong Mee <kinglongmee@gmail.com> wrote:
> > 
> >> On 8/20/2014 18:58, Jeff Layton wrote:
> >>> On Wed, 20 Aug 2014 18:07:19 +0800
> >>> Kinglong Mee <kinglongmee@gmail.com> wrote:
> >>>
> >>>> Fix left code by Joe Perches's patch,
> >>>> "locks: Remove unused conf argument from lm_grant"
> >>>>
> >>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >>>> ---
> >>>>  fs/lockd/svclock.c          | 26 +++++---------------------
> >>>>  include/linux/lockd/lockd.h |  1 -
> >>>>  2 files changed, 5 insertions(+), 22 deletions(-)
> >>>>
> >>>> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> >>>> index 2a61701..796e63b 100644
> >>>> --- a/fs/lockd/svclock.c
> >>>> +++ b/fs/lockd/svclock.c
> >>>> @@ -245,7 +245,6 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
> >>>>  	block->b_daemon = rqstp->rq_server;
> >>>>  	block->b_host   = host;
> >>>>  	block->b_file   = file;
> >>>> -	block->b_fl = NULL;
> >>>>  	file->f_count++;
> >>>>  
> >>>>  	/* Add to file's list of blocks */
> >>>> @@ -295,7 +294,6 @@ static void nlmsvc_free_block(struct kref *kref)
> >>>>  	nlmsvc_freegrantargs(block->b_call);
> >>>>  	nlmsvc_release_call(block->b_call);
> >>>>  	nlm_release_file(block->b_file);
> >>>> -	kfree(block->b_fl);
> >>>>  	kfree(block);
> >>>>  }
> >>>>  
> >>>> @@ -523,20 +521,13 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> >>>>  	block = nlmsvc_lookup_block(file, lock);
> >>>>  
> >>>>  	if (block == NULL) {
> >>>> -		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
> >>>> -
> >>>> -		if (conf == NULL)
> >>>> -			return nlm_granted;
> >>>>  		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
> >>>> -		if (block == NULL) {
> >>>> -			kfree(conf);
> >>>> +		if (block == NULL)
> >>>>  			return nlm_granted;
> >>>> -		}
> >>>> -		block->b_fl = conf;
> >>>
> >>> NAK. The b_fl member is not unused, as is evidenced by the assignment
> >>> above.
> >>
> >> Sorry for my bad title, Maybe I should use a good name, sorry!
> >>
> >>>
> >>> Joe's patch removed the conflock from the lm_grant callback since the
> >>> filesystem never set that parameter in the lm_grant callback. This call
> >>> however has nothing to do with lm_grant. It's done when the client
> >>> issues a NLM_TEST operation.
> >>>
> >>>>  	}
> >>>>  	if (block->b_flags & B_QUEUED) {
> >>>> -		dprintk("lockd: nlmsvc_testlock deferred block %p flags %d fl %p\n",
> >>>> -			block, block->b_flags, block->b_fl);
> >>>> +		dprintk("lockd: nlmsvc_testlock deferred block %p flags %d\n",
> >>>> +			block, block->b_flags);
> >>>>  		if (block->b_flags & B_TIMED_OUT) {
> >>>>  			nlmsvc_unlink_block(block);
> >>>>  			ret = nlm_lck_denied;
> >>>> @@ -544,14 +535,8 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> >>>>  		}
> >>>>  		if (block->b_flags & B_GOT_CALLBACK) {
> >>>>  			nlmsvc_unlink_block(block);
> >>>> -			if (block->b_fl != NULL
> >>>> -					&& block->b_fl->fl_type != F_UNLCK) {
> >>>> -				lock->fl = *block->b_fl;
> >>>> -				goto conf_lock;
> >>
> >> block->b_fl = conf just set an all-zero filed structure to block above,
> >> and never be updated later.
> >> If lockd enter here, lock->fl will contains all filed with zero,
> >> I don't know whether is it OK.
> >>
> >> thanks,
> >> Kinglong Mee
> >>
> > 
> > Not quite....You can end up getting back FILE_LOCK_DEFERRED from an
> > initial vfs_test_lock request. At that point, a block will be queued
> > and we'll end up retrying that until the fs comes back. The result of
> > those retries will end up in b_fl and that's what will end up being
> > copied to lock->fl.
> 
> Yes, that's right.
> What I　care is that block->b_fl contains with all zero for all field, 
> block->b_fl->fl_type == 0 == F_RDLCK.
> 
> For block with b_flags & B_GOT_CALLBACK, block->b_fl will always be non-NULL,
> and block->b_fl->fl_type always be F_RDLCK (Cannot be updated after initial),
> so that, nlmsvc_testlock will return nlm_lck_denied,
> but I think should return nlm_granted.
> 
> So, I think commit 5ea0d75037b9 (lockd: handle test_lock deferrals)
> introduces the bug. After Joe's patch, we should remove b_fl in struct block.
> 
> Cc Marc Eshel
> 
> 506 __be32
> 507 nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> 508                 struct nlm_host *host, struct nlm_lock *lock,
> 509                 struct nlm_lock *conflock, struct nlm_cookie *cookie)
> 510 {
> 511         struct nlm_block        *block = NULL;
> ... ...
> 536         }
> 537         if (block->b_flags & B_QUEUED) {
> 538                 dprintk("lockd: nlmsvc_testlock deferred block %p flags %d fl %p\n",
> 539                         block, block->b_flags, block->b_fl);
> 540                 if (block->b_flags & B_TIMED_OUT) {
> 541                         nlmsvc_unlink_block(block);
> 542                         ret = nlm_lck_denied;
> 543                         goto out;
> 544                 }
> 545                 if (block->b_flags & B_GOT_CALLBACK) {
> 546                         nlmsvc_unlink_block(block);
> 547                         if (block->b_fl != NULL
> 548                                         && block->b_fl->fl_type != F_UNLCK) {
>                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> 549                                 lock->fl = *block->b_fl;
> 550                                 goto conf_lock;
> 551                         } else {
> 552                                 ret = nlm_granted;
> 553                                 goto out;
> 554                         }
> 555                 }
> 
> thanks,
> Kinglong Mee

Yeah, that certainly looks wrong, and now that I look I don't see where
the callback code touches b_fl at all. Maybe you're right here...

Furthermore, I don't see how you can get FILE_LOCK_DEFERRED in this
codepath at all. The generic locking code will only send that back if
FL_SLEEP is set in the request (and it isn't here).

The DLM code just looks broken. It never returns FILE_LOCK_DEFERRED in
the GETLK codepath and instead ignores FL_SLEEP, does a blocking upcall
and waits on the reply. That likely makes lockd stall out regularly...

Wonder if there are any out of tree filesystems that rely on this? GPFS
maybe?

Ok, I'm sold. I'll take your patch and let it stew in linux-next for a
bit, and we can look at merging it for v3.18.

-- 
Jeff Layton <jlayton@primarydata.com>

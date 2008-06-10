From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Tue, 10 Jun 2008 15:13:57 -0400
Message-ID: <20080610151357.150b6f69@tleilax.poochiereds.net>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	<20080604203504.62730951@tleilax.poochiereds.net>
	<1213124088.20459.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daniel J Blueman <daniel.blueman@gmail.com>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbYFJTOI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 15:14:08 -0400
In-Reply-To: <1213124088.20459.16.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Jun 2008 14:54:48 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Wed, 2008-06-04 at 20:35 -0400, Jeff Layton wrote:
> > On Thu, 5 Jun 2008 00:33:54 +0100
> > "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
> > 
> > > Having experienced 'mount.nfs4: internal error' when mounting nfsv4 in
> > > the past, I have a minimal test-case I sometimes run:
> > > 
> > > $ while :; do mount -t nfs4 filer:/store /store; umount /store; done
> > > 
> > > After ~100 iterations, I saw the 'mount.nfs4: internal error',
> > > followed by symptoms of memory corruption [1], a locking issue with
> > > the reporting [2] and another (related?) memory-corruption issue
> > > (off-by-1?) [3]. A little analysis shows memory being overwritten by
> > > (likely) a poison value, which gets complicated if it's not
> > > use-after-free...
> > > 
> > > Anyone dare confirm this issue? NFSv4 server is x86-64 Ubuntu 8.04
> > > 2.6.24-18, client U8.04 2.6.26-rc4; batteries included [4].
> > > 
> > > I'm happy to decode addresses, test patches etc.
> > > 
> > > Daniel
> > > 
> > 
> > Looks like it fell down while trying to take down the kthread during a
> > failed mount attempt. I have to wonder if I might have introduced a
> > race when I changed nfs4 callback thread to kthread API. I think we may
> > need the BKL around the last 2 statements in the main callback thread
> > function. If you can easily reproduce this, could you test the
> > following patch and let me know if it helps?
> > 
> > Note that this patch is entirely untested, so test it someplace
> > non-critical ;-).
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > 
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index c1e7c83..a3e83f9 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -90,9 +90,9 @@ nfs_callback_svc(void *vrqstp)
> >  		preverr = err;
> >  		svc_process(rqstp);
> >  	}
> > -	unlock_kernel();
> >  	nfs_callback_info.task = NULL;
> >  	svc_exit_thread(rqstp);
> > +	unlock_kernel();
> >  	return 0;
> >  }
> 
> We certainly need to protect nfs_callback_info.task (and I believe I
> explained this earlier), but why do we need to protect svc_exit_thread?
> 
> Also, looking at the general use of the BKL in that code, I thought we
> agreed that there was no need to hold the BKL while taking the
> nfs_callback_mutex?
> 

Hmm, I don't remember that discussion, but I'll take your word for it...

I think you're basically correct, but it looks to me like the
nfs_callback_mutex actually protects nfs_callback_info.task as well.

If we're starting the thread, then we can't call kthread_stop on it
until we release the mutex. So the thread can't exit until we release
the mutex, and we can be guaranteed that this:

     nfs_callback_info.task = NULL;

...can't happen until after kthread_run returns and nfs_callback_up
sets it.

If that's right, then maybe this (untested, RFC only) patch would make sense?

----------[snip]------------

>From cd0ce86919ede3f1abda1ba7522b72283bb94d7e Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 10 Jun 2008 15:12:16 -0400
Subject: [PATCH] nfs4: remove BKL from nfs_callback_up and nfs_callback_down

The nfs_callback_mutex is sufficient protection. We don't need the
BKL here.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index c1e7c83..9e713d2 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -105,7 +105,6 @@ int nfs_callback_up(void)
 	struct svc_rqst *rqstp;
 	int ret = 0;
 
-	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
@@ -149,7 +148,6 @@ out:
 	if (serv)
 		svc_destroy(serv);
 	mutex_unlock(&nfs_callback_mutex);
-	unlock_kernel();
 	return ret;
 out_err:
 	dprintk("Couldn't create callback socket or server thread; err = %d\n",
@@ -163,13 +161,11 @@ out_err:
  */
 void nfs_callback_down(void)
 {
-	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
 	nfs_callback_info.users--;
 	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL)
 		kthread_stop(nfs_callback_info.task);
 	mutex_unlock(&nfs_callback_mutex);
-	unlock_kernel();
 }
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
-- 
1.5.3.6


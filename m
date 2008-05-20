From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove	signaling
 for shutdown
Date: Tue, 20 May 2008 13:26:47 -0700
Message-ID: <48333407.8020007@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>	<4831F860.6050801@melbourne.sgi.com>	<18482.4782.858347.981553@notabene.brown>	<20080519222457.6f24daa5@tupile.poochiereds.net> <18482.16837.381955.636390@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:60637 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758367AbYETU3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 16:29:17 -0400
In-Reply-To: <18482.16837.381955.636390-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
>
> Fair question.
> The new nfsd_mutex primarily protects "nfsd_serv", both the pointer
> itself and various members of the structure that it sometimes points
> to.
> In particular, ->sv_nrthreads but also to some extent sv_temp_socks
> and sv_permsocks.
>   
Those two fields should be guarded by svc_serv->sv_lock only.  In fact
IIRC the only field of svc_serv guarded by the global mutex is
sv_nrthreads in it's role as pseudo-refcount.

> Having said all that, I think I see a race.
> When a new rqst is created at put on sp_all_threads, ->rq_task it not
> set and doesn't get set until the thread runs and gets the mutex.  So
> there is a brief hole when ->rq_task isn't set.  I don't know if that
> can cause a problem, but it feels wrong.
> When you switch to kthreads, you use the fact that kthread_create
> returns a task_struct, and assign that to ->rq_task in
> __svc_create_thread instead of nfsd, which will close that hole.
>   
Yes, that aspect of Jeff's patch is a definite improvement.
> If you look in nfsctl.c, you will probably be able to find plenty of
> places where nfsd_serv is dereferenced without any locking.  These are
> all wrong and need fixing.
>   
Agreed!

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.


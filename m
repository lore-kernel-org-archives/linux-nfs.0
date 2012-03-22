Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab2CVOfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 10:35:44 -0400
Date: Thu, 22 Mar 2012 15:27:58 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
        David Rientjes <rientjes@google.com>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()
	API
Message-ID: <20120322142758.GA12370@redhat.com>
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F6A92FC.6060702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21, Boaz Harrosh wrote:
>
> > @@ -258,7 +262,8 @@ static void __call_usermodehelper(struct work_struct *work)
> >
> >  	switch (wait) {
> >  	case UMH_NO_WAIT:
> > -		call_usermodehelper_freeinfo(sub_info);
> > +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
> > +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
> >  		break;

This doesn't look very nice. If you add the refcounting, it should be
consistent. Imho it is better to change call_usermodehelper_exec() so
that UMH_NO_WAIT does kref_put() too. Just s/goto unlock/goto out/ afaics.

> > @@ -452,22 +459,27 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info,
> >
> >  	sub_info->complete = &done;
> >  	sub_info->wait = wait;
> > +	if (!sub_info->wait_timeout)
> > +		sub_info->wait_timeout = MAX_SCHEDULE_TIMEOUT;
> >
> > +	/* Balanced in __call_usermodehelper or wait_for_helper */
> > +	kref_get(&sub_info->kref);
> >  	queue_work(khelper_wq, &sub_info->work);
> >  	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
> >  		goto unlock;
> > -	wait_for_completion(&done);
> > -	retval = sub_info->retval;
> > -
> > +	if (likely(wait_for_completion_timeout(&done, sub_info->wait_timeout)))
> > +		retval = sub_info->retval;
> > +	else
> > +		retval = -ETIMEDOUT;
> >  out:
> > -	call_usermodehelper_freeinfo(sub_info);
> > +	kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
> >  unlock:
> >  	helper_unlock();
> >  	return retval;
> >  }

This looks obviously wrong. You also need to move *sub_info->complete
into subprocess_info.

> Author: Oleg Nesterov <oleg@redhat.com>
> Date:   Wed Mar 21 10:57:41 2012 +1100
>
>     usermodehelper: implement UMH_KILLABLE
>
>     Implement UMH_KILLABLE, should be used along with UMH_WAIT_EXEC/PROC.  The
>     caller must ensure that subprocess_info->path/etc can not go away until
>     call_usermodehelper_freeinfo().
> ...
>
> I think that my patch above does a much better/cleaner lifetime management of the
> subprocess_info struct, with the use of a kref.

This is subjective, you know ;) I specially tried to avoid the
refcounting.

In any case. I do not know why do we need timeout, but this is
orthogonal to KILLABLE. Please redo your patches on top of -mm
tree? Please note that in this case the change becomes trivial.

And please explain the use-case for the new API.

> Anyway I thought that we are not
> suppose to use xhcg() since it is not portable to all ARCHs. ;-)

Hmm. For example, exit_mm() does xchg().

Oleg.


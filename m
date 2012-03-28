Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758013Ab2C1Qor (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 12:44:47 -0400
Date: Wed, 28 Mar 2012 18:35:45 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        linux-security-module@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>,
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
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Subject: Re: [PATCH 6/6] kmod: optional: Convert the use of xchg to a kref
Message-ID: <20120328163545.GA18944@redhat.com>
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com> <4F7122C0.2070800@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F7122C0.2070800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26, Boaz Harrosh wrote:
>
> if we use a kref instead of xchg to govern the lifetime
> of struct subprocess_info, the code becomes simpler and
> more generic. We can avoid some of the special cases.

Looks correct, and perhaps this makes the code more understandable.
If we use kref, we have to move the completion into subprocess_info,
but this allows to remove the "fallback to wait_for_completion()"
subtleness. Up to maintainer.

However, I agree with Peter, wait_for_completion_timeout_state()
helper from 4/6 needs more discussion.

And the previous looks patch is wrong, see my reply. The bug goes
away after this patch, but this is not good anyway. IOW, I think
you should redo 5 and 6 even if the resulting code looks correct.

Just one nit below.

> Actually I like the xchg use here. But if it will break
> some ARCHs that do not like xchg, then here is the work
> needed.

Well, xchg() has other arch-neutral users. But again, I am not
arguing with this change.

> @@ -302,7 +297,7 @@ static void __call_usermodehelper(struct work_struct *work)
>
>  	switch (wait) {
>  	case UMH_NO_WAIT:
> -		call_usermodehelper_freeinfo(sub_info);
> +		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
>  		break;

This is minor and subjective, but UMH_NO_WAIT could use umh_complete()
too, the unnecessary complete() doesn't hurt. In this case we could do


	switch (wait) {
	case UMH_WAIT_PROC:
		if (pid > 0)
			break;
		/* FALLTHROUGH */
	case UMH_WAIT_EXEC:
		if (pid < 0)
			sub_info->retval = pid;
		/* FALLTHROUGH */
	case UMH_NO_WAIT:
		umh_complete(sub_info);
	}

Oleg.


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:36104 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758228Ab3EDNAf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2013 09:00:35 -0400
Date: Sat, 4 May 2013 15:00:33 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130504130033.GB13770@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367615050-3894-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

> NFS calls the freezable helpers with locks held, which is unsafe
> and caused lockdep warnings when 6aa9707 "lockdep: check that no
> locks held at freeze time" was applied (reverted in dbf520a).
> Add new *_unsafe versions of the helpers that will not run the
> lockdep test when 6aa9707 is reapplied, and call them from NFS.
> 
> Signed-off-by: Colin Cross <ccross@android.com>

Looks mostly good.

> @@ -152,6 +169,14 @@ static inline bool freezer_should_skip(struct task_struct *p)
>  	freezer_count();						\
>  })
>  
> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> +#define freezable_schedule_unsafe()					\
> +({									\
> +	freezer_do_not_count();						\
> +	schedule();							\
> +	freezer_count_unsafe();						\
> +})
> +

Make it inline function? :-). Add short explanation why it is good
idea?

> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> +#define freezable_schedule_timeout_killable_unsafe(timeout)		\
> +({									\
> +	long __retval;							\
> +	freezer_do_not_count();						\
> +	__retval = schedule_timeout_killable(timeout);			\
> +	freezer_count_unsafe();						\
> +	__retval;							\
> +})

Function too?
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

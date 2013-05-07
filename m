Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:47136 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757131Ab3EGM2I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 May 2013 08:28:08 -0400
Date: Tue, 7 May 2013 14:28:04 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Len Brown <len.brown@intel.com>
Subject: Re: [PATCH v3 02/16] freezer: add unsafe versions of freezable
 helpers for CIFS
Message-ID: <20130507122803.GA2585@elf.ucw.cz>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
 <1367884221-20462-3-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367884221-20462-3-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2013-05-06 16:50:07, Colin Cross wrote:
> CIFS calls wait_event_freezekillable_unsafe with a VFS lock held,
> which is unsafe and will cause lockdep warnings when 6aa9707
> "lockdep: check that no locks held at freeze time" is reapplied
> (it was reverted in dbf520a).  CIFS shouldn't be doing this, but
> it has long-running syscalls that must hold a lock but also
> shouldn't block suspend.  Until CIFS freeze handling is rewritten
> to use a signal to exit out of the critical section, add a new
> wait_event_freezekillable_unsafe helper that will not run the
> lockdep test when 6aa9707 is reapplied, and call it from CIFS.
> 
> In practice the likley result of holding the lock while freezing
> is that a second task blocked on the lock will never freeze,
> aborting suspend, but it is possible to manufacture a case using
> the cgroup freezer, the lock, and the suspend freezer to create
> a deadlock.  Silencing the lockdep warning here will allow
> problems to be found in other drivers that may have a more
> serious deadlock risk, and prevent new problems from being added.
> 
> Signed-off-by: Colin Cross <ccross@android.com>

Acked-by: Pavel Machek <pavel@ucw.cz>

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

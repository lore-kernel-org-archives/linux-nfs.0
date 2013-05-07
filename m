Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:47201 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757931Ab3EGM3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 May 2013 08:29:09 -0400
Date: Tue, 7 May 2013 14:29:07 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>,
        Len Brown <len.brown@intel.com>
Subject: Re: [PATCH v3 04/16] lockdep: check that no locks held at freeze time
Message-ID: <20130507122906.GC2585@elf.ucw.cz>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
 <1367884221-20462-5-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367884221-20462-5-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2013-05-06 16:50:09, Colin Cross wrote:
> From: Mandeep Singh Baines <msb@chromium.org>
> 
> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
> deadlock if the lock is later acquired in the suspend or hibernate path
> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
> cgroup_freezer if a lock is held inside a frozen cgroup that is later
> acquired by a process outside that group.
> 
> History:
> This patch was originally applied as 6aa9707099c and reverted in
> dbf520a9d7d4 because NFS was freezing with locks held.  It was
> deemed better to keep the bad freeze point in NFS to allow laptops
> to suspend consistently.  The previous patch in this series converts
> NFS to call _unsafe versions of the freezable helpers so that
> lockdep doesn't complain about them until a more correct fix
> can be applied.
> 
> [akpm@linux-foundation.org: export debug_check_no_locks_held]
> Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
> Cc: Ben Chan <benchan@chromium.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Cc: Ingo Molnar <mingo@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> [ccross@android.com: don't warn if try_to_freeze_unsafe is called]
> Signed-off-by: Colin Cross <ccross@android.com>

Acked-by: Pavel Machek <pavel@ucw.cz>

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

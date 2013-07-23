Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:46414 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab3GWA0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 20:26:30 -0400
Date: Tue, 23 Jul 2013 02:26:28 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Michael Leun <lkml20130126@newton.leun.net>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re:
 [PATCH v3 13/16] futex: use freezable blocking call)
Message-ID: <20130723002627.GA11751@amd.pavel.ucw.cz>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
 <1367884221-20462-14-git-send-email-ccross@android.com>
 <20130723010250.5a3465ec@xenia.leun.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130723010250.5a3465ec@xenia.leun.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 2013-07-23 01:02:50, Michael Leun wrote:
> On Mon,  6 May 2013 16:50:18 -0700
> Colin Cross <ccross@android.com> wrote:
> 
> > Avoid waking up every thread sleeping in a futex_wait call during
> [...]
> 
> With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
> displaying 0% of saving image to disk.
> 
> echo "1" >/sys/power/state still works.
> 
> Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4, reverting
> that from 3.11-rc2 makes s2disk working again.

Would id be possible to get all the backtraces using magic sysrq?

...actually...

I see what could happen. Before, system hibernated in state where all
the futexes were unlocked. Now, it can happen that we attempt s2disk
with futex held. s2disk should not depend on other parts of userspace,
and should not take futexes, but maybe it does...?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

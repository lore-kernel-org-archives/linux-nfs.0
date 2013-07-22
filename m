Return-Path: linux-nfs-owner@vger.kernel.org
Received: from stator.leun.net ([85.214.203.199]:38834 "EHLO stator.leun.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482Ab3GVXfg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 19:35:36 -0400
Date: Tue, 23 Jul 2013 01:02:50 +0200
From: Michael Leun <lkml20130126@newton.leun.net>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
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
Subject: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH
 v3 13/16] futex: use freezable blocking call)
Message-ID: <20130723010250.5a3465ec@xenia.leun.net>
In-Reply-To: <1367884221-20462-14-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon,  6 May 2013 16:50:18 -0700
Colin Cross <ccross@android.com> wrote:

> Avoid waking up every thread sleeping in a futex_wait call during
[...]

With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
displaying 0% of saving image to disk.

echo "1" >/sys/power/state still works.

Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4, reverting
that from 3.11-rc2 makes s2disk working again.

-- 
MfG,

Michael Leun


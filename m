Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:47164 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758562Ab3EGM2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 May 2013 08:28:25 -0400
Date: Tue, 7 May 2013 14:28:23 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Paul Walmsley <paul@pwsan.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v3 03/16] lockdep: remove task argument from
 debug_check_no_locks_held
Message-ID: <20130507122823.GB2585@elf.ucw.cz>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
 <1367884221-20462-4-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367884221-20462-4-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2013-05-06 16:50:08, Colin Cross wrote:
> The only existing caller to debug_check_no_locks_held calls it
> with 'current' as the task, and the freezer needs to call
> debug_check_no_locks_held but doesn't already have a current
> task pointer, so remove the argument.  It is already assuming
> that the current task is relevant by dumping the current stack
> trace as part of the warning.
> 
> This was originally part of 6aa9707099c (lockdep: check that
> no locks held at freeze time) which was reverted in
> dbf520a9d7d4.
> 
> Original-author: Mandeep Singh Baines <msb@chromium.org>
> Signed-off-by: Colin Cross <ccross@android.com>

Acked-by: Pavel Machek <pavel@ucw.cz>

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

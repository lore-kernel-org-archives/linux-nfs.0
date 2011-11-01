Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57585 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab1KASGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Nov 2011 14:06:08 -0400
Date: Tue, 1 Nov 2011 11:06:01 -0700
From: Tejun Heo <tj@kernel.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
 fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111101180601.GV18855@google.com>
References: <20111031221743.GA18855@google.com>
 <201111010024.16659.rjw@sisk.pl>
 <20111031233059.GI18855@google.com>
 <20111101005505.GO18855@google.com>
 <20111101041337.39077229@tlielax.poochiereds.net>
 <20111101065958.50addab5@tlielax.poochiereds.net>
 <20111101163059.GR18855@google.com>
 <20111101175953.GB5358@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111101175953.GB5358@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 01, 2011 at 06:59:53PM +0100, Oleg Nesterov wrote:
> > #define wait_event_freezekillable(wq, condition)			\
> > do {									\
> > 	DEFINE_WAIT(__wait);						\
> > 	for (;;) {							\
> > 		prepare_to_wait(&wq, &__wait, TASK_INTERRUPTIBLE);	\
> > 		if (condition || fatal_signal_pending(current))		\
> > 			break;						\
> > 		schedule();						\
> 
> No, this can't work, afaics.
> 
> Once the caller recieves a non-fatal signal (gets TIF_SIGPENDING),
> schedule() won't block in TASK_INTERRUPTIBLE state.
> 
> IOW, wait_event_freezekillable() becomes a busy-wait loop.

Yeah yeah, Trond already pointed it out.  I forgot about the
sigpending special case in schedule(), which I think is rather odd, oh
well.  Any better ideas?

-- 
tejun

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51068 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab1KAQzl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Nov 2011 12:55:41 -0400
Date: Tue, 1 Nov 2011 09:55:35 -0700
From: Tejun Heo <tj@kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        Oleg Nesterov <oleg@redhat.com>, linux-pm@vger.kernel.org,
        linux-cifs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
 fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111101165535.GU18855@google.com>
References: <20111031221743.GA18855@google.com>
 <201111010024.16659.rjw@sisk.pl>
 <20111031233059.GI18855@google.com>
 <20111101005505.GO18855@google.com>
 <20111101041337.39077229@tlielax.poochiereds.net>
 <20111101065958.50addab5@tlielax.poochiereds.net>
 <20111101163059.GR18855@google.com>
 <1320166171.5019.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320166171.5019.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Tue, Nov 01, 2011 at 12:49:31PM -0400, Trond Myklebust wrote:
> > #define wait_event_freezekillable(wq, condition)			\
> > do {									\
> > 	DEFINE_WAIT(__wait);						\
> > 	for (;;) {							\
> > 		prepare_to_wait(&wq, &__wait, TASK_INTERRUPTIBLE);	\
> > 		if (condition || fatal_signal_pending(current))		\
> > 			break;						\
> > 		schedule();						\
> > 		try_to_freeze();					\
> > 	}								\
> > 	finish_wait(&wq, &__wait);					\
> > } while (0)
> 
> Err... Won't this end up busy-waiting if a non-fatal signal is received?

Ah... right, forgot about signal_pending_state() special case in
schedule().  Any better ideas, anyone?

-- 
tejun

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369Ab1KBQ17 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 12:27:59 -0400
Date: Wed, 2 Nov 2011 17:23:31 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Jeff Layton <jlayton@redhat.com>, Steve French <sfrench@samba.org>,
        linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-cifs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
	fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111102162331.GA31947@redhat.com>
References: <20111101041337.39077229@tlielax.poochiereds.net> <20111101065958.50addab5@tlielax.poochiereds.net> <20111101163059.GR18855@google.com> <20111101175953.GB5358@redhat.com> <20111101180601.GV18855@google.com> <20111101181329.GA6739@redhat.com> <20111101182753.GW18855@google.com> <20111101193923.GA9444@redhat.com> <20111101194601.GB9444@redhat.com> <20111101215710.GA13803@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111101215710.GA13803@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On 11/01, Tejun Heo wrote:
>
> For now, let's go with the count/dont_count.  Can you please write up
> a patch for that?  Jeff, does this seem okay to you?

OK, will do in a minute. On top of
"[PATCH pm] freezer: fix wait_event_freezable/__thaw_task races"
you sent. (btw, thanks, I forgout about it ;)

Rafael, could you remind why freezer_do_not_count/freezer_count check
->mm != NULL ?

The comment says "However, we don't want kernel threads to be frozen",
but it is not clear anyway. A kernel thread simply shouldn't use this
interface if it doesn't want to freeze.

And in any case, PF_KTHREAD looks better if we really need to filter
out the kernel threads.

Oleg.


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:53303 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293Ab1KCPae (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 11:30:34 -0400
Date: Thu, 3 Nov 2011 08:30:27 -0700
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] wait_event_freezekillable: use
 freezer_do_not_count/freezer_count
Message-ID: <20111103153027.GE4417@google.com>
References: <20111101180601.GV18855@google.com>
 <20111101181329.GA6739@redhat.com>
 <20111101182753.GW18855@google.com>
 <20111101193923.GA9444@redhat.com>
 <20111101194601.GB9444@redhat.com>
 <20111101215710.GA13803@google.com>
 <20111102175327.GA4446@redhat.com>
 <20111103064215.48939e1a@tlielax.poochiereds.net>
 <20111103141354.GB4417@google.com>
 <20111103112704.4b905bfc@barsoom.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111103112704.4b905bfc@barsoom.rdu.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Thu, Nov 03, 2011 at 11:27:04AM -0400, Jeff Layton wrote:
> Ok, note though that I also need to do a similar set of changes to the
> nfs and sunrpc code [1].
> 
> Those call sites do not use wait_event_* macros though. So I'll either
> need to add a separate set of functions/macros to handle those, or
> sprinkle freezer_do_not_count/freezer_count around the code there...

Yes, I still think it would be better to isolate implementation
details from users.  I really hate to see the 'count' functions
scattered around the kernel.

Thank you.

-- 
tejun

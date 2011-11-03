Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64097 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab1KCOOB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 10:14:01 -0400
Date: Thu, 3 Nov 2011 07:13:54 -0700
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] wait_event_freezekillable: use
 freezer_do_not_count/freezer_count
Message-ID: <20111103141354.GB4417@google.com>
References: <20111101163059.GR18855@google.com>
 <20111101175953.GB5358@redhat.com>
 <20111101180601.GV18855@google.com>
 <20111101181329.GA6739@redhat.com>
 <20111101182753.GW18855@google.com>
 <20111101193923.GA9444@redhat.com>
 <20111101194601.GB9444@redhat.com>
 <20111101215710.GA13803@google.com>
 <20111102175327.GA4446@redhat.com>
 <20111103064215.48939e1a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111103064215.48939e1a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Thu, Nov 03, 2011 at 06:42:15AM -0400, Jeff Layton wrote:
> I'm not sure we really need this macro anymore since this is much
> simpler. I could just move cifs back to using wait_event_killable and
> simply wrap it in freezer_do_not_count/freezer_count (with some
> comments to explain why we're doing that).
> 
> In any event, I plan to test this scheme out today and will let you
> know whether it works...

I think it would be better to put this in a macro as the
implementation is likely to change in future and I really don't want
to see FREEZER_SKIP scattered around the tree.

Thank you.

-- 
tejun

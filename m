Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab0FJNoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 09:44:10 -0400
Date: Thu, 10 Jun 2010 09:45:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd bugfixes for 2.6.35
Message-ID: <20100610094503.0c7a7637@corrin.poochiereds.net>
In-Reply-To: <20100609191246.GA12134@fieldses.org>
References: <20100609191246.GA12134@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 9 Jun 2010 15:12:47 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> These two nfsd bugfixes are suitable for 2.6.35:
> 
>   git://linux-nfs.org/~bfields/linux.git for-2.6.35
> 
> Christoph Hellwig (1):
>       nfsd: nfsd_setattr needs to call commit_metadata
> 
> J. Bruce Fields (2):
>       nfsd4: shut down callback queue outside state lock
>       Merge branch 'for-2.6.34-incoming' into for-2.6.35-incoming
> 
> commit 44b56603c4c476b845a824cff6fe905c6268b2a1
> Merge: c3935e3 b160fda
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Tue Jun 8 20:05:18 2010 -0400
> 
>     Merge branch 'for-2.6.34-incoming' into for-2.6.35-incoming
> 
> commit c3935e30495869dd611e1cd62253c94ebc7c6c04
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Fri Jun 4 16:42:08 2010 -0400
> 
>     nfsd4: shut down callback queue outside state lock
>     
>     This reportedly causes a lockdep warning on nfsd shutdown.  That looks
>     like a false positive to me, but there's no reason why this needs the
>     state lock anyway.
>     
>     Reported-by: Jeff Layton <jlayton@redhat.com>
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 

FWIW, I figured out the reason for this yesterday...

When destroy_workqueue holds the cpu_add_remove_lock while it's
flushing the workqueue during shutdown. The laundry_wq job locks the
state during its work, so the locks are taken like this:

#0: cpu_add_remove_lock
#1: client_mutex

...after shutting down the laundry_wq, we go to shut down the
callback_wq. While doing that, we take and hold the client_mutex and
then call destroy_workqueue. Now we end up with the locks taken in the
reverse order and we get the lockdep splatter:

#0: client_mutex
#1: cpu_add_remove_lock

...moving the destroy of the callback_wq outside of the client_mutex
seems like the easiest and best fix.

-- 
Jeff Layton <jlayton@redhat.com>

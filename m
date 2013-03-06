Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41869 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3CFVkW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 16:40:22 -0500
Date: Wed, 6 Mar 2013 13:40:16 -0800
From: Tejun Heo <tj@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306214016.GQ1227@htj.dyndns.org>
References: <20130305140312.243cb094@tlielax.poochiereds.net>
 <20130305190923.GI12795@htj.dyndns.org>
 <20130305183941.19ff39ce@tlielax.poochiereds.net>
 <20130305234700.GE1227@htj.dyndns.org>
 <20130306181608.GA18687@redhat.com>
 <20130306185304.GM1227@htj.dyndns.org>
 <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
 <20130306212452.GO1227@htj.dyndns.org>
 <CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
 <20130306213636.GP1227@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130306213636.GP1227@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 06, 2013 at 01:36:36PM -0800, Tejun Heo wrote:
> On Wed, Mar 06, 2013 at 01:31:10PM -0800, Linus Torvalds wrote:
> > So I do agree that we probably have *too* many of the stupid "let's
> > check if we can freeze", and I suspect that the NFS code should get
> > rid of the "freezable_schedule()" that is causing this warning
> > (because I also agree that you should *not* freeze while holding
> > locks, because it really can cause deadlocks), but I do suspect that
> > network filesystems do need to have a few places where they check for
> > freezing on their own... Exactly because freezing isn't *quite* like a
> > signal.
> 
> Well, I don't really know much about nfs so I can't really tell, but
> for most other cases, dealing with freezing like a signal should work
> fine from what I've seen although I can't be sure before actually
> trying.  Trond, Bruce, can you guys please chime in?

So, I think the question here would be, in nfs, how many of the
current freezer check points would be difficult to conver to signal
handling model after excluding the ones which are performed while
holding some locks which we need to get rid of anyway?

Thanks.

-- 
tejun

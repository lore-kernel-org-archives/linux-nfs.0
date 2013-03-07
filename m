Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:44189 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289Ab3CGPZL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2013 10:25:11 -0500
Date: Thu, 7 Mar 2013 07:25:04 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Oleg Nesterov <oleg@redhat.com>,
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
Message-ID: <20130307152504.GA29601@htj.dyndns.org>
References: <20130305190923.GI12795@htj.dyndns.org>
 <20130305183941.19ff39ce@tlielax.poochiereds.net>
 <20130305234700.GE1227@htj.dyndns.org>
 <20130306181608.GA18687@redhat.com>
 <20130306185304.GM1227@htj.dyndns.org>
 <CA+55aFwDogteVd=vwGHXDSASnga-nZZnKaQz9aO1yBU2CPKSbA@mail.gmail.com>
 <20130306212452.GO1227@htj.dyndns.org>
 <CA+55aFy49AWptMcvEzJxg95ikf-dC+-vcCPq-cnaCCwje3tyoQ@mail.gmail.com>
 <20130306213636.GP1227@htj.dyndns.org>
 <20130307064140.71c0936b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130307064140.71c0936b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jeff.

On Thu, Mar 07, 2013 at 06:41:40AM -0500, Jeff Layton wrote:
> Suppose I call unlink("somefile"); on an NFS mount. We take all of the
> VFS locks, go down into the NFS layer. That marshals up the UNLINK
> call, sends it off to the server, and waits for the reply. While we're
> waiting, a freeze event comes in and we start returning from the
> kernel with our new -EFREEZE return code that works sort of like
> -ERESTARTSYS. Meanwhile, the server is processing the UNLINK call and
> removes the file. A little while later we wake up the machine and it
> goes to try and pick up where it left off.

But you can't freeze regardless of the freezing mechanism in such
cases, right?  The current code which allows freezing while such
operations are in progress is broken as it can lead to freezer
deadlocks.  They should go away no matter how we implement freezer, so
the question is not whether we can move all the existing freezing
points to signal mechanism but that, after removing the deadlock-prone
ones, how many would be difficult to convert.  I'm fully speculating
but my suspicion is not too many if you remove (or update somehow) the
ones which are being done with some locks held.

> The catch here is that it's quite possible that when we need to quiesce
> that we've lost communications with the server. We don't want to hold
> up the freezer at that point so the wait for replies has to be bounded
> in time somehow. If that times out, we probably just have to return all
> calls with our new -EFREEZE return and hope for the best when the
> machine wakes back up.

Sure, a separate prep step may be helpful but assuming a user
nfs-mounting stuff on a laptop, I'm not sure how reliable that can be
made.  People move around with laptops, wifi can be iffy and the lid
can be shut at any moment.  I don't think it's possible for nfs to be
laptop friendly while staying completely correct.  Designing such a
network filesystem probably is possible with transactions and whatnot
but AFAIU nfs isn't designed that way.  If such use case is something
nfs wants to support, I think it just should make do with some
middleground - ie. just implement a mount switch which says "retry
operations across network / power problems" and explain the
implications.

Thanks.

-- 
tejun

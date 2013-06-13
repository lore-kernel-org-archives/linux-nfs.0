Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362Ab3FMPVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 11:21:12 -0400
Date: Thu, 13 Jun 2013 11:20:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 12/14] locks: give the blocked_hash its own spinlock
Message-ID: <20130613152036.GC20666@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
 <1370948948-31784-13-git-send-email-jlayton@redhat.com>
 <20130613150247.GB20666@fieldses.org>
 <20130613111844.59421622@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130613111844.59421622@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:18:44AM -0400, Jeff Layton wrote:
> On Thu, 13 Jun 2013 11:02:47 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Jun 11, 2013 at 07:09:06AM -0400, Jeff Layton wrote:
> > > There's no reason we have to protect the blocked_hash and file_lock_list
> > > with the same spinlock. With the tests I have, breaking it in two gives
> > > a barely measurable performance benefit, but it seems reasonable to make
> > > this locking as granular as possible.
> > 
> > Out of curiosity...  In the typical case when adding/removing a lock,
> > aren't both lists being modified in rapid succession?
> > 
> > I wonder if it would be better to instead stick with one lock and take
> > care to acquire it only once to cover both manipulations.
> > 
> > --b.
> > 
> 
> That's not really the case...
> 
> Typically, when doing a call into __posix_lock_file with FL_SLEEP set,
> we either end up blocking on the lock or acquiring it. In either case,
> we'll only end up taking one of the global spinlocks. The reason for
> this is that blocker is what dequeues a waiter from the blocked_hash
> before waking it up (in locks_wake_up_posix_blocks).
> 
> Also, while this patch description doesn't spell it out, we require a
> truly global lock for deadlock detection. In a later patch though, I
> convert the file_lock_lock to a per-cpu spinlock. So we really do need
> to separate the locks here in order to make the per-cpu file_lock_list
> worthwhile.

Oh, right, got it!

--b.

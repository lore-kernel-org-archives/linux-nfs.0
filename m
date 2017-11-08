Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50866 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752503AbdKHVnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 16:43:45 -0500
Date: Wed, 8 Nov 2017 16:43:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: fix locking validator warning on
 nfs4_ol_stateid->st_mutex class
Message-ID: <20171108214344.GQ24262@fieldses.org>
References: <20171108005726.35092-1-aweits@rit.edu>
 <20171108205812.GP24262@fieldses.org>
 <m21sl8o3bd.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m21sl8o3bd.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 08, 2017 at 04:42:14PM -0500, Andrew W Elble wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > On Tue, Nov 07, 2017 at 07:57:26PM -0500, Andrew Elble wrote:
> >> The use of the st_mutex has been confusing the validator. Use the
> >> proper nested notation so as to not produce warnings.
> >
> > Looking around, the usual pattern for simple nesting seems to be to use
> > just mutex_lock() for the outer lock (equivalent to
> > mutex_lock_nested(0)), and mutex_lock_nested(., SINGLE_DEPTH_NESTING)
> > for the inner lock.
> >
> > Or we could define a new LOCK_STATEID_MUTEX, assuming the rule here is
> > "lock stateid's are locked after open stateid's".  Just a question of
> > might be simpler to understand.
> 
> I'm okay with whatever you think is best here - my thought was that the
> mutex_lock_nested(0) called more attention to how it was working given
> that acquiring that lock class the second time is now a little bit more
> hidden in nfsd4_lock_ol_stateid().

I think I'd go for constants like OPEN_STATEID_MUTEX and
LOCK_STATEID_MUTEX in that case.  Maybe mild overkill, but it should
explain what's going on?

--b.

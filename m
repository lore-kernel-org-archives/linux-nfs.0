Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42869 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069Ab0EUVHp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 17:07:45 -0400
Date: Fri, 21 May 2010 17:07:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jeff Layton <jlayton@redhat.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk,
        jamie@shareable.org
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
	file
Message-ID: <20100521210738.GK11675@fieldses.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <1273859968.4732.22.camel@localhost.localdomain> <1273861872.4732.34.camel@localhost.localdomain> <20100514192327.GA20192@fieldses.org> <4BF3B36F.80209@cn.fujitsu.com> <20100519155700.GE4581@fieldses.org> <4BF504DE.7010804@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BF504DE.7010804@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 20, 2010 at 05:46:06PM +0800, Mi Jinlong wrote:
> J. Bruce Fields :
> > I don't know of any existing lock that does exactly what we want.
> > 
> > Somebody at citi worked on a better lease implementation for a while,
> > but I don't think we ever really got it right; the last version I can
> > find is here:
> > 
> > 	git://linux-nfs.org/~bfields/linux-topics.git leases
> 
>   When reading the code of the git, i found a patch which try to fix
>   the lease's problem, but only for unlink.

It's 8 patches together:

>   commit id: d5a08e556116c66fb60a448f805a40bf54314634
>         msg: "leases: break file leases on unlink."
> 
>   In this patch, it seems only add break_lease() and some other functions
>   but seems don't avoid the problem of race.

Look again: break_lease() is there, but there's also a break_lease_end()
after the unlink.

> Or there is some different 
>   at break_lease() with the community's kernel.
> 
>   Can you give me some message about the new lease? Thanks.

So the 8 patches at that branch are:
	leases: introduce per-inode lease enabling/disabling
	VFS: clean up extra dereferences in do_unlinkat()
	leases: break file leases on unlink.
	leases: break file leases on rename.
	leases: break leases on chown.
	VFS: refactor sys_fchmod and sys_fchmodat
	leases: break leases on chmod.
	leases: break leases on link.

Like I say, I don't think they're correct or I'd just copy them all to
the list.  But maybe the comment on the first patch (appended) is
useful.

--b.

leases: introduce per-inode lease enabling/disabling

The current file lease implementation is inadequate (for the purposes of
nfs, and, we believe, for the purposes of Samba), in at least two ways:

	- Leases are broken only conflicting opens; but both nfsv4
	  delegations and (we're told) Windows op locks actually require
	  that leases be broken on any operation that changes file
	  metadata--including unlink, link, rename, chmod, and chown.

	- The internal kernel api used for lease-breaking is inherently
	  racy, consisting as it does of a single break_lease() call.
	  (Consider this scenario: a file is not currently open and is
	  about to be unlinked.  During unlink processing, a lookup is
	  done, and break_lease() is called.  After the break_lease(),
	  but before the unlink completes, another user opens the file
	  and gets a read lease.  The unlink then completes, but the
	  other user thinks their read lease is still valid.  This
	  situation would be avoided if lease-granting for the inode
	  were disabled for the duration of the unlink.)

We're primarily interested in the case of read leases for now.  (Write
leases, which also must be broken on *access* to a file, are more
difficult to get completely right, and aren't used by the current nfs
server.)

Fixing the second problem requires replacing break_lease() by a pair of
calls, here called break_lease() and break_lease_end(), between which
new leases are temporarily prohibited.

We want to implement that temporary prohibition in a simple way that has
low impact in common (uncontended) cases.

This patch adds a field, i_leasecount, which provides mutual exclusion
between inode-modifying operations and read leases in the same way the
i_writecount provides mutual exclusion between write opens and execs:
when i_leasecount is positive, it counts the number of leases on the
given inode, and when it's negative it counts the number of operations
which want leases temporarily disabled.  This allows selective
enabling/disabling of leases on a per-inode basis.

To that end, the functions leases_get_access() and leases_put_access()
are used when a lease is granted and returned, respectively.  The
functions leases_deny_access() and leases_allow_access() are used to
prevent races between breaking-with-FMODE_WRITE and write-lease-granting
for the entire duration of a file operation.  Currently, leases are
broken only when a file is opened or truncated; these functions will
allow leases to be broken on things like unlink and rename as well.
NFSv4 implements delegations using leases, and needs its delegations to
be revoked on unlinks, renames, chowns, etc.

Note that this patch changes break_lease() and __break_lease(), such
that when they are called with FMODE_WRITE and return successfully, they
will leave leases disabled on the inode in question, and the caller must
eventually call break_lease_end() to re-enable leasing.  As alluded to
in the scenario above, this behavior isn't necessary when breaking
without FMODE_WRITE: existing and new read-leases wouldn't need to be
revoked or blocked; and a write-lease-granting setlease won't race the
break_lease() because the latter is presumed to have been preceded by
something like a dget() on the dentry in question (where d_count or
i_count > 1 blocks write-lease-granting).

This patch also closes a small existing open/lease race: a lease-related
race exists between the time that outstanding leases are broken (by
may_open()) and the time that, e.g., O_RDWR or O_WRONLY are reflected in
the inode's i_writecount variable (which will prevent subsequent
lease-granting setlease calls).  Conceivably, a read lease could be
granted in the interim.

To deal with this, may_open() is modified so that, on success and when
called with FMODE_WRITE, it will return with lease-granting disabled for
the inode in question.  do_filp_open() is modified so that leasing is
re-enabled once everything is finished.  Analogous changes are made on
truncation.

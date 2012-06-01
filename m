Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55359 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758733Ab2FAA4F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 20:56:05 -0400
Date: Thu, 31 May 2012 20:56:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: nfsd changes for 3.5
Message-ID: <20120601005603.GA28542@fieldses.org>
References: <20120531182457.GB25955@fieldses.org>
 <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
 <20120531200138.GD25955@fieldses.org>
 <CA+55aFyuHz5Vn8G_kpKgnSStX0s125gwwQij2KXmnhfwaajhkg@mail.gmail.com>
 <20120531205300.GG25955@fieldses.org>
 <CA+55aFxY+WJmMu=1Wvdh24kK0JWEuQ1vwcqZdaNDbp1_wUsZ4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+55aFxY+WJmMu=1Wvdh24kK0JWEuQ1vwcqZdaNDbp1_wUsZ4A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 03:14:57PM -0700, Linus Torvalds wrote:
> On Thu, May 31, 2012 at 1:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, May 31, 2012 at 01:17:26PM -0700, Linus Torvalds wrote:
> >
> > Uh, that means ditching some work in my public git tree.  Which I
> > haven't rebased in years.  So, a stupid process question; would you
> > rather I:
> >
> >        - continue to be strict about rebasing and apply a bunch of
> >          reverts?
> >        - ditch it and start over?
> 
> I think in this case rebasing is the right thing to do.
> 
> I hate rebasing, but what I hate about it is how people who use it as
> a development model cause problems for anybody else. I don't think it
> will cause problems in this particular case, but if somebody hollers,
> let me know.

OK, will do.

For now, would you mind pulling this?:

	git://linux-nfs.org/~bfields/linux.git for-3.5-take-2

It's literally just the previous tree cut off before the delegation
stuff--so it's been in -next for a month, etc.

--b.

Jeff Layton (3):
      nfsd: trivial: remove unused variable from nfsd4_lock
      nfsd: don't use locks_in_grace to determine whether to call nfs4_grace_end
      nfsd: trivial: use SEEK_SET instead of 0 in vfs_llseek

Simo Sorce (2):
      svcauth: remove unused define
      SUNRPC: split upcall function to extract reusable parts

Stanislav Kinsbursky (18):
      nfsd: use passed cache_detail pointer expkey_parse()
      nfsd: add link to owner cache detail to svc_export structure
      nfsd: use cache detail pointer from svc_export structure on cache put
      nfsd: use exp_put() for svc_export_cache put
      nfsd: pass svc_export_cache pointer as private data to "exports" seq file ops
      nfsd: use hash table from cache detail in nfsd export seq ops
      nfsd: pass pointer to expkey cache down to stack wherever possible.
      NFSd: remove hard-coded dereferences to name-to-id and id-to-name caches
      Lockd: pass network namespace to creation and destruction routines
      nfsd: pass network context to export caches init/shutdown routines
      nfsd: pass pointer to export cache down to stack wherever possible.
      nfsd: make export cache allocated per network namespace context
      nfsd: make expkey cache allocated per network namespace context
      nfsd: allocate export and expkey caches in per-net operations.
      nfsd: pass network context to idmap init/exit functions
      nfsd: make id-to-name cache allocated per network namespace context
      nfsd: make name-to-id cache allocated per network namespace context
      nfsd: allocate id-to-name and name-to-id caches in per-net operations.

 fs/lockd/clntlock.c               |   13 +--
 fs/lockd/svc.c                    |    7 +-
 fs/nfsd/export.c                  |  175 ++++++++++++++++++++++---------------
 fs/nfsd/idmap.h                   |    8 +-
 fs/nfsd/netns.h                   |    6 ++
 fs/nfsd/nfs4idmap.c               |  109 +++++++++++++----------
 fs/nfsd/nfs4state.c               |   13 ++-
 fs/nfsd/nfsctl.c                  |   55 ++++++++----
 fs/nfsd/nfsfh.c                   |    2 +-
 fs/nfsd/nfssvc.c                  |    8 +-
 fs/nfsd/vfs.c                     |    2 +-
 include/linux/lockd/bind.h        |    4 +-
 include/linux/nfsd/export.h       |   13 ++-
 include/linux/sunrpc/svcauth.h    |    3 +-
 net/sunrpc/auth_gss/svcauth_gss.c |  100 +++++++++++++--------
 net/sunrpc/svcauth_unix.c         |   13 +--
 16 files changed, 322 insertions(+), 209 deletions(-)

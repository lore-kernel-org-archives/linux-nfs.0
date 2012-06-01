Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55731 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759437Ab2FALRd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 07:17:33 -0400
Date: Fri, 1 Jun 2012 07:17:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: nfsd changes for 3.5
Message-ID: <20120601111732.GB31104@fieldses.org>
References: <20120531182457.GB25955@fieldses.org>
 <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
 <20120531200138.GD25955@fieldses.org>
 <CA+55aFyuHz5Vn8G_kpKgnSStX0s125gwwQij2KXmnhfwaajhkg@mail.gmail.com>
 <20120531205300.GG25955@fieldses.org>
 <CA+55aFxY+WJmMu=1Wvdh24kK0JWEuQ1vwcqZdaNDbp1_wUsZ4A@mail.gmail.com>
 <20120601005603.GA28542@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120601005603.GA28542@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 08:56:03PM -0400, J. Bruce Fields wrote:
> For now, would you mind pulling this?:
> 
> 	git://linux-nfs.org/~bfields/linux.git for-3.5-take-2
> 
> It's literally just the previous tree cut off before the delegation
> stuff--so it's been in -next for a month, etc.


... and then I cherry-picked the remainder of the patches from the head
of my previous branch to:

  git://linux-nfs.org/~bfields/linux.git for-3.5

and ran some tests overnight--no surprises, as they're all quite
independent from the delegation stuff.  But if they've missed 3.5 it's
not a tragedy.

--b.

Chuck Lever (1):
      NFSD: SETCLIENTID_CONFIRM returns NFS4ERR_CLID_INUSE too often

J. Bruce Fields (34):
      nfsd: state.c should include current_stateid.h
      nfsd4: fix missing "static"
      nfsd4: preserve __user annotation on cld downcall msg
      nfsd4: int/__be32 fixes
      nfsd4: fix free_stateid return endianness
      nfsd4: fix change attribute endianness
      rpc: handle rotated gss data for Windows interoperability
      svcrpc: fix a comment typo
      nfsd4: exchange_id has a pointless copy
      nfsd4: exchange_id error cleanup
      nfsd4: exchange_id: check creds before killing confirmed client
      nfsd4: allow an EXCHANGE_ID to kill a 4.0 client
      nfsd4: exchange_id cleanup: local shorthands for repeated tests
      nfsd4: exchange_id cleanup: comments
      nfsd4: rearrange exchange_id logic to simplify
      nfsd4: allow removing clients not holding state
      nfsd4: move principal name into svc_cred
      nfsd4: stricter cred comparison for setclientid/exchange_id
      nfsd4: move rq_flavor into svc_cred
      nfsd4: setclientid remove unnecessary terms from a logical expression
      nfsd4: setclientid/confirm comment cleanup
      nfsd4: merge last two setclientid cases
      nfsd4: pull out common code from setclientid cases
      nfsd4: merge 3 setclientid cases to 2
      nfsd4: fix setclientid_confirm same_cred check
      nfsd4: fix error return in non-matching-creds case
      nfsd4: setclientid: remove pointless assignment
      nfsd4: simpler ordering of setclientid_confirm checks
      nfsd4: clarify that renewing expired client is a bug
      nfsd4: fix exchange_id to return confirm flag
      nfsd4: return "real" sequence id in confirmed case
      nfsd4: remove some dprintk's and a comment
      nfsd4: don't remove rebooted client record until confirmation
      nfsd4: fix, consolidate client_has_state

Jeff Layton (5):
      sunrpc: do array overrun check in svc_recv before allocating pages
      nfsd: consolidate set_access and set_deny
      nfsd: make test_share a bool return
      nfsd: wrap accesses to st_access_bmap
      nfsd: wrap all accesses to st_deny_bmap

Stanislav Kinsbursky (8):
      SUNRPC: new svc_bind() routine introduced
      SUNRPC: move per-net operations from svc_destroy()
      LockD: pass service to per-net up and down functions
      LockD: use existing per-net data function on service creation
      LockD: service creation function introduced
      LockD: move global usage counter manipulation from error path
      LockD: service start function introduced
      LockD: add debug message to start and stop functions

Weston Andros Adamson (2):
      nfsd: add IPv6 addr escaping to fs_location hosts
      nfsd: return 0 on reads of fault injection files

 fs/lockd/svc.c                      |  145 ++++++----
 fs/nfs/callback.c                   |   13 +-
 fs/nfsd/auth.c                      |    2 +-
 fs/nfsd/export.c                    |    8 +-
 fs/nfsd/fault_inject.c              |    1 +
 fs/nfsd/nfs4callback.c              |    5 +-
 fs/nfsd/nfs4idmap.c                 |    4 +-
 fs/nfsd/nfs4recover.c               |    4 +-
 fs/nfsd/nfs4state.c                 |  525 ++++++++++++++++-------------------
 fs/nfsd/nfs4xdr.c                   |   62 +++--
 fs/nfsd/nfsctl.c                    |   12 +-
 fs/nfsd/nfssvc.c                    |   23 ++
 fs/nfsd/state.h                     |    1 -
 fs/nfsd/xdr4.h                      |    6 +-
 include/linux/sunrpc/svc.h          |    2 +-
 include/linux/sunrpc/svcauth.h      |   10 +
 include/linux/sunrpc/svcauth_gss.h  |    1 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c |   61 ++--
 net/sunrpc/auth_gss/svcauth_gss.c   |   27 +-
 net/sunrpc/rpcb_clnt.c              |   12 +-
 net/sunrpc/svc.c                    |   23 +-
 net/sunrpc/svc_xprt.c               |    4 +-
 net/sunrpc/svcauth_unix.c           |    6 +-
 23 files changed, 522 insertions(+), 435 deletions(-)

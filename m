Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C763C04EB8
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 01:47:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C429A2082B
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 01:47:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C429A2082B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726570AbeLEBrO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 20:47:14 -0500
Received: from fieldses.org ([173.255.197.46]:49500 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725841AbeLEBrK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Dec 2018 20:47:10 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 74EA43F5; Tue,  4 Dec 2018 20:47:10 -0500 (EST)
Date:   Tue, 4 Dec 2018 20:47:10 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "neilb@suse.com" <neilb@suse.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 00/23 - V5] NFS: Remove generic RPC credentials.
Message-ID: <20181205014710.GB6093@fieldses.org>
References: <154379689752.28598.6750646657534626618.stgit@noble>
 <20181204202103.GD3903@fieldses.org>
 <19ce8a518de95a0c0185eccefbf17da5ebceda11.camel@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19ce8a518de95a0c0185eccefbf17da5ebceda11.camel@netapp.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 04, 2018 at 09:33:18PM +0000, Schumaker, Anna wrote:
> On Tue, 2018-12-04 at 15:21 -0500, J. Bruce Fields wrote:
> > On Mon, Dec 03, 2018 at 11:30:30AM +1100, NeilBrown wrote:
> > > This is the same series as posted on 07 November, modified slightly
> > > to match some recent code changes upstream - nothing substantial.
> > > 
> > > General description:
> > > 
> > > There doesn't seem to be a maintainer for the 'cred' code, so I don't
> > > know who to ask to approve the first 4 patches.  Maybe if the NFS
> > > team like them, they can just go to Linus with a note for him to look
> > > at them if he wants to.
> > 
> > For what it's worth: all my usual tests still pass with this series
> > applied.  And the nfsd (and common) parts are unlikely to conflict with
> > anything of mine.
> > 
> > Otherwise: sounds like a reasonable idea, but I haven't gotten a chance
> > to review the patches in any detail.
> 
> The patches look okay to me, I'm was planning to take them for the next merge.
> 
> Bruce, can I get your acked-by for the patches that touch NFSD?  I think it's
> just 19/23.

Yes, feel free to add 

	Acked-by: J. Bruce Fields <bfields@redhat.com>

--b.

> 
> Thanks,
> Anna
> 
> > 
> > --b.
> > 
> > > The original motivation for this was performance.  In some
> > > circumstances the cred caches can get big and particularly can get
> > > long chains.  The hash function has been changed at least once to
> > > improve the hashing and it still isn't perfect.
> > > Rather than improving pruning of the cache, or resizing the hashtable
> > > etc, it is easiest to just get rid of it.
> > > 
> > > As well as discarding generic credentials completely (using 'struct
> > > cred' instead), we also stop storing AUTH_UNIX credentials in a hash
> > > table - that brings no value.  Just allocate as needed and discard
> > > when finished with.
> > > So the only hash table will still have is for AUTH_GSS.
> > > One of the main triggers for hashtable problems was users changing
> > > groups a lot, so there would be many entries for the one user, each
> > > with a different set of groups.  That doesn't apply for
> > > AUTH_GSS as the groupids on the client are ignored.
> > > 
> > > That was the original motivation, but as I worked on it, I realized
> > > that it was making a log of code simpler.
> > > 
> > >  44 files changed, 550 insertions(+), 925 deletions(-)
> > > 
> > > That is sufficient motivation in itself I think.
> > > 
> > > Thanks,
> > > NeilBrown
> > > 
> > > 
> > > ---
> > > 
> > > NeilBrown (23):
> > >       cred: add cred_fscmp() for comparing creds.
> > >       cred: add get_cred_rcu()
> > >       cred: export get_task_cred().
> > >       cred: allow get_cred() and put_cred() to be given NULL.
> > >       SUNRPC: add 'struct cred *' to auth_cred and rpc_cred
> > >       SUNRPC: remove groupinfo from struct auth_cred.
> > >       SUNRPC: remove uid and gid from struct auth_cred
> > >       SUNRPC: remove machine_cred field from struct auth_cred
> > >       NFSv4: add cl_root_cred for use when machine cred is not available.
> > >       NFSv4: don't require lock for get_renew_cred or get_machine_cred
> > >       SUNRPC: discard RPC_DO_ROOTOVERRIDE()
> > >       NFS/SUNRPC: don't lookup machine credential until rpcauth_bindcred().
> > >       SUNRPC: introduce RPC_TASK_NULLCREDS to request auth_none
> > >       SUNRPC: add side channel to use non-generic cred for rpc call.
> > >       NFS: move credential expiry tracking out of SUNRPC into NFS.
> > >       SUNRPC: remove RPCAUTH_AUTH_NO_CRKEY_TIMEOUT
> > >       NFS: change access cache to use 'struct cred'.
> > >       NFS: struct nfs_open_dir_context: convert rpc_cred pointer to cred.
> > >       NFS/NFSD/SUNRPC: replace generic creds with 'struct cred'.
> > >       SUNRPC: remove generic cred code.
> > >       SUNRPC: remove crbind rpc_cred operation
> > >       SUNRPC: simplify auth_unix.
> > >       SUNRPC discard cr_uid from struct rpc_cred.
> > > 
> > > 
> > >  fs/lockd/clntproc.c                       |    6 -
> > >  fs/nfs/blocklayout/blocklayout.c          |    2 
> > >  fs/nfs/client.c                           |    9 -
> > >  fs/nfs/delegation.c                       |   28 +--
> > >  fs/nfs/delegation.h                       |   10 -
> > >  fs/nfs/dir.c                              |   59 ++----
> > >  fs/nfs/flexfilelayout/flexfilelayout.c    |   64 +++---
> > >  fs/nfs/flexfilelayout/flexfilelayout.h    |    8 -
> > >  fs/nfs/flexfilelayout/flexfilelayoutdev.c |   16 +-
> > >  fs/nfs/inode.c                            |   13 +
> > >  fs/nfs/internal.h                         |    8 -
> > >  fs/nfs/nfs3proc.c                         |    4 
> > >  fs/nfs/nfs4_fs.h                          |   65 +++---
> > >  fs/nfs/nfs4client.c                       |    4 
> > >  fs/nfs/nfs4proc.c                         |  150 +++++++--------
> > >  fs/nfs/nfs4renewd.c                       |    9 -
> > >  fs/nfs/nfs4session.c                      |    5 
> > >  fs/nfs/nfs4state.c                        |  129 ++++++-------
> > >  fs/nfs/pagelist.c                         |    2 
> > >  fs/nfs/pnfs.c                             |   14 +
> > >  fs/nfs/pnfs.h                             |   10 -
> > >  fs/nfs/pnfs_dev.c                         |    4 
> > >  fs/nfs/pnfs_nfs.c                         |    2 
> > >  fs/nfs/proc.c                             |    2 
> > >  fs/nfs/unlink.c                           |   15 -
> > >  fs/nfs/write.c                            |   24 ++
> > >  fs/nfsd/nfs4callback.c                    |   31 +--
> > >  fs/nfsd/state.h                           |    2 
> > >  include/linux/cred.h                      |   26 ++-
> > >  include/linux/nfs_fs.h                    |   13 +
> > >  include/linux/nfs_fs_sb.h                 |    2 
> > >  include/linux/nfs_xdr.h                   |   16 +-
> > >  include/linux/sunrpc/auth.h               |   51 -----
> > >  include/linux/sunrpc/clnt.h               |    1 
> > >  include/linux/sunrpc/sched.h              |    6 -
> > >  kernel/cred.c                             |   58 ++++++
> > >  net/sunrpc/Makefile                       |    2 
> > >  net/sunrpc/auth.c                         |  116 ++++++-----
> > >  net/sunrpc/auth_generic.c                 |  293 --------------------------
> > > ---
> > >  net/sunrpc/auth_gss/auth_gss.c            |   47 +----
> > >  net/sunrpc/auth_null.c                    |    4 
> > >  net/sunrpc/auth_unix.c                    |  110 +++--------
> > >  net/sunrpc/clnt.c                         |   26 +--
> > >  net/sunrpc/sched.c                        |    5 
> > >  44 files changed, 551 insertions(+), 920 deletions(-)
> > >  delete mode 100644 net/sunrpc/auth_generic.c
> > > 
> > > --
> > > Signature

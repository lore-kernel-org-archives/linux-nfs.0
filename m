Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3EEBC04EB9
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 23:19:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 947D62146D
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 23:19:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 947D62146D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726572AbeK3K02 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 05:26:28 -0500
Received: from mx2.suse.de ([195.135.220.15]:39826 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726406AbeK3K01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 05:26:27 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 7FAB3AE25;
        Thu, 29 Nov 2018 23:19:14 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Fri, 30 Nov 2018 10:19:05 +1100
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 00/23 - V4] NFS: Remove generic RPC credentials.
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
Message-ID: <87sgzjo4k6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,
 has anyone else had a chance to look at this yet?

 There is a small conflict now due to
        SUNRPC: Fix a bogus get/put in generic_key_to_expire()
 Should I resend with that fixed up?

Thanks,
NeilBrown


On Wed, Nov 07 2018, NeilBrown wrote:

> This is an updated version of a series I sent in Feb of this year.
> Since then there have only been minor improvement and updates to sync
> with the changing kernel.
>
> There doesn't seem to be a maintainer for the 'cred' code, so I don't
> know who to ask to approve the first 4 patches.  Maybe if the NFS
> team like them, they can just go to Linus with a note for him to look
> at them if he wants to.
>
> The original motivation for this was performance.  In some
> circumstances the cred caches can get big and particularly can get
> long chains.  The hash function has been changed at least once to
> improve the hashing and it still isn't perfect.
> Rather than improving pruning of the cache, or resizing the hashtable
> etc, it is easiest to just get rid of it.
>
> As well as discarding generic credentials completely (using 'struct
> cred' instead), we also stop storing AUTH_UNIX credentials in a hash
> table - that brings no value.  Just allocate as needed and discard
> when finished with.
> So the only hash table will still have is for AUTH_GSS.
> One of the main triggers for hashtable problems was users changing
> groups a lot, so there would be many entries for the one user, each
> with a different set of groups.  That doesn't apply for
> AUTH_GSS as the groupids on the client are ignored.
>
> That was the original motivation, but as I worked on it, I realized
> that it was making a log of code simpler.
>
>  44 files changed, 550 insertions(+), 925 deletions(-)
>
> That is sufficient motivation in itself I think.
>
> Review comments most welcome.
>
> Thanks,
> NeilBrown
>
>
> ---
>
> NeilBrown (23):
>       cred: add cred_fscmp() for comparing creds.
>       cred: add get_cred_rcu()
>       cred: export get_task_cred().
>       cred: allow get_cred() and put_cred() to be given NULL.
>       SUNRPC: add 'struct cred *' to auth_cred and rpc_cred
>       SUNRPC: remove groupinfo from struct auth_cred.
>       SUNRPC: remove uid and gid from struct auth_cred
>       SUNRPC: remove machine_cred field from struct auth_cred
>       NFSv4: add cl_root_cred for use when machine cred is not available.
>       NFSv4: don't require lock for get_renew_cred or get_machine_cred
>       SUNRPC: discard RPC_DO_ROOTOVERRIDE()
>       NFS/SUNRPC: don't lookup machine credential until rpcauth_bindcred(=
).
>       SUNRPC: introduce RPC_TASK_NULLCREDS to request auth_none
>       SUNRPC: add side channel to use non-generic cred for rpc call.
>       NFS: move credential expiry tracking out of SUNRPC into NFS.
>       SUNRPC: remove RPCAUTH_AUTH_NO_CRKEY_TIMEOUT
>       NFS: change access cache to use 'struct cred'.
>       NFS: struct nfs_open_dir_context: convert rpc_cred pointer to cred.
>       NFS/NFSD/SUNRPC: replace generic creds with 'struct cred'.
>       SUNRPC: remove generic cred code.
>       SUNRPC: remove crbind rpc_cred operation
>       SUNRPC: simplify auth_unix.
>       SUNRPC discard cr_uid from struct rpc_cred.
>
>
>  fs/lockd/clntproc.c                       |    6 -
>  fs/nfs/blocklayout/blocklayout.c          |    2=20
>  fs/nfs/client.c                           |    9 -
>  fs/nfs/delegation.c                       |   28 +--
>  fs/nfs/delegation.h                       |   10 -
>  fs/nfs/dir.c                              |   59 ++----
>  fs/nfs/flexfilelayout/flexfilelayout.c    |   64 +++---
>  fs/nfs/flexfilelayout/flexfilelayout.h    |    8 -
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c |   16 +-
>  fs/nfs/inode.c                            |   13 +
>  fs/nfs/internal.h                         |    8 -
>  fs/nfs/nfs3proc.c                         |    4=20
>  fs/nfs/nfs4_fs.h                          |   65 +++---
>  fs/nfs/nfs4client.c                       |    4=20
>  fs/nfs/nfs4proc.c                         |  150 +++++++--------
>  fs/nfs/nfs4renewd.c                       |    9 -
>  fs/nfs/nfs4session.c                      |    5=20
>  fs/nfs/nfs4state.c                        |  129 ++++++-------
>  fs/nfs/pagelist.c                         |    2=20
>  fs/nfs/pnfs.c                             |   14 +
>  fs/nfs/pnfs.h                             |   10 -
>  fs/nfs/pnfs_dev.c                         |    4=20
>  fs/nfs/pnfs_nfs.c                         |    2=20
>  fs/nfs/proc.c                             |    2=20
>  fs/nfs/unlink.c                           |   15 -
>  fs/nfs/write.c                            |   24 ++
>  fs/nfsd/nfs4callback.c                    |   31 +--
>  fs/nfsd/state.h                           |    2=20
>  include/linux/cred.h                      |   26 ++-
>  include/linux/nfs_fs.h                    |   13 +
>  include/linux/nfs_fs_sb.h                 |    2=20
>  include/linux/nfs_xdr.h                   |   16 +-
>  include/linux/sunrpc/auth.h               |   51 -----
>  include/linux/sunrpc/clnt.h               |    1=20
>  include/linux/sunrpc/sched.h              |    6 -
>  kernel/cred.c                             |   58 ++++++
>  net/sunrpc/Makefile                       |    2=20
>  net/sunrpc/auth.c                         |  116 ++++++-----
>  net/sunrpc/auth_generic.c                 |  299 -----------------------=
------
>  net/sunrpc/auth_gss/auth_gss.c            |   45 +---
>  net/sunrpc/auth_null.c                    |    4=20
>  net/sunrpc/auth_unix.c                    |  110 +++--------
>  net/sunrpc/clnt.c                         |   26 +--
>  net/sunrpc/sched.c                        |    5=20
>  44 files changed, 550 insertions(+), 925 deletions(-)
>  delete mode 100644 net/sunrpc/auth_generic.c
>
> --
> Signature

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwAc+kACgkQOeye3VZi
gbmh7g/8DyWHiQ6A3zCV0m07aT2x6DR6/UBRfhOeAzAbnH51eQ+fmlDWQh8xLAfM
KOL7lYvbO7bZXcjonSJNZeRvridaxu/45NjSuCFP5Gd1zt2WaHQ5/QpqasQPPEeU
NQbHuLmd5f3Pk4r78jX7/+EJixvhH1EJmjsFAJUbxb0LBbUw51rwRlxOT4T0ynmm
1ihzm2dbPLh/dcutZCwYv9pcbfnV2P1YAMlUUCkYVc/VGiyNlEm0MNqXk67+ZT9w
PHsmyWpT7xxeaHvjKED+6r+7wFo4Z2agnxvAxWA0gngbNQH1MRP3ESQBv3WPu6sN
KVHBYxAVPEmfDWWocQv4OjTBUBIwJzgzyY/tnq3alCuetsyXZldkYRigamxV219b
rFivORNCsTjrtT9ai/hm93hSEMvNriJnEa05JL1iFuqGK6pOfeRnTJUI5iemg2Jb
hkRzZ8XPn3RRAAlzuqW8tJ4ZrySwRsM1gQpXl2He23+XjJZJyNAHsKWzvzpvRpfN
qosk6KsCMcJ1ivN+yKqcbuLBnjABMfc8bQWH2p1P7zh0rDSxw33NFKD6ItrBiUc8
fgMYN0DlfNiE2pLVoIqkre5adH8fOmx2dNRtQ0JBtpz9Djrf1Eo0VontZ7lcTSr5
qb8VR93xCjrJewjxauM8bsBiLR3y8lLAJAAAH2B0Ep+UdsX+ycU=
=WwbL
-----END PGP SIGNATURE-----
--=-=-=--

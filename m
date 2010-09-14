Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34276 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567Ab0INCLv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 22:11:51 -0400
Subject: [GIT PULL] Please pull bugfixes for the NFS client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 13 Sep 2010 22:11:32 -0400
Message-ID: <1284430292.6811.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/Kconfig                       |    1 +
 fs/nfs/client.c                      |    2 +-
 fs/nfs/file.c                        |    4 -
 fs/nfs/super.c                       |   10 +++-
 fs/nfsd/Kconfig                      |    1 +
 include/linux/sunrpc/clnt.h          |    2 +-
 net/sunrpc/auth.c                    |    2 +-
 net/sunrpc/auth_gss/auth_gss.c       |    9 ++-
 net/sunrpc/auth_gss/gss_krb5_mech.c  |   10 +++-
 net/sunrpc/auth_gss/gss_spkm3_mech.c |    5 +-
 net/sunrpc/clnt.c                    |  116 +++++++++++++++++-----------------
 net/sunrpc/rpc_pipe.c                |   20 +++---
 12 files changed, 99 insertions(+), 83 deletions(-)

commit 827e3457022d0bb0b1bb8a0eb88501876fe7dcf0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 12 19:57:50 2010 -0400

    SUNRPC: Fix the NFSv4 and RPCSEC_GSS Kconfig dependencies
    
    The NFSv4 client's callback server calls svc_gss_principal(), which
    is defined in the auth_rpcgss.ko
    
    The NFSv4 server has the same dependency, and in addition calls
    svcauth_gss_flavor(), gss_mech_get_by_pseudoflavor(),
    gss_pseudoflavor_to_service() and gss_mech_put() from the same module.
    
    The module auth_rpcgss itself has no dependencies aside from sunrpc,
    so we only need to select RPCSEC_GSS.
    
    Reported-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fbf3fdd2443965d9ba6fb4b5fecd1f6e0847218f
Author: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Date:   Sun Sep 12 19:55:26 2010 -0400

    statfs() gives ESTALE error
    
    Hi,
    
    An NFS client executes a statfs("file", &buff) call.
    "file" exists / existed, the client has read / written it,
    but it has already closed it.
    
    user_path(pathname, &path) looks up "file" successfully in the
    directory-cache  and restarts the aging timer of the directory-entry.
    Even if "file" has already been removed from the server, because the
    lookupcache=positive option I use, keeps the entries valid for a while.
    
    nfs_statfs() returns ESTALE if "file" has already been removed from the
    server.
    
    If the user application repeats the statfs("file", &buff) call, we
    are stuck: "file" remains young forever in the directory-cache.
    
    Signed-off-by: Zoltan Menyhart  <Zoltan.Menyhart@bull.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit b20d37ca9561711c6a3c4b859c2855f49565e061
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 12 19:55:26 2010 -0400

    NFS: Fix a typo in nfs_sockaddr_match_ipaddr6
    
    Reported-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit db5fe26541b6b48460104a0d949a27cdc7786957
Author: Miquel van Smoorenburg <mikevs@xs4all.net>
Date:   Sun Sep 12 19:55:26 2010 -0400

    sunrpc: increase MAX_HASHTABLE_BITS to 14
    
    The maximum size of the authcache is now set to 1024 (10 bits),
    but on our server we need at least 4096 (12 bits). Increase
    MAX_HASHTABLE_BITS to 14. This is a maximum of 16384 entries,
    each containing a pointer (8 bytes on x86_64). This is
    exactly the limit of kmalloc() (128K).
    
    Signed-off-by: Miquel van Smoorenburg <mikevs@xs4all.net>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 651b2933b22a0c060e6bb940c4104eb447a61f9a
Author: Bian Naimeng <biannm@cn.fujitsu.com>
Date:   Sun Sep 12 19:55:26 2010 -0400

    gss:spkm3 miss returning error to caller when import security context
    
    spkm3 miss returning error to up layer when import security context,
    it may be return ok though it has failed to import security context.
    
    Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ce8477e1176389ed920550f4c925ad4a815b22d5
Author: Bian Naimeng <biannm@cn.fujitsu.com>
Date:   Sun Sep 12 19:55:25 2010 -0400

    gss:krb5 miss returning error to caller when import security context
    
    krb5 miss returning error to up layer when import security context,
    it may be return ok though it has failed to import security context.
    
    Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b1bde04c6d9a120dec602cc8a70b8a7f21600883
Author: Fabio Olive Leite <fleite@redhat.com>
Date:   Sun Sep 12 19:55:25 2010 -0400

    Remove incorrect do_vfs_lock message
    
    The do_vfs_lock function on fs/nfs/file.c is only called if NLM is
    not being used, via the -onolock mount option. Therefore it cannot
    really be "out of sync with lock manager" when the local locking
    function called returns an error, as there will be no corresponding
    call to the NLM. For details, simply check the if/else on do_setlk
    and do_unlk on fs/nfs/file.c.
    
    Signed-Off-By: Fabio Olive Leite <fleite@redhat.com>
    Reviewed-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 55576244eba805307a2b2b6a145b8f85f8c7c124
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Sep 12 19:55:25 2010 -0400

    SUNRPC: cleanup state-machine ordering
    
    This is just a minor cleanup: net/sunrpc/clnt.c clarifies the rpc client
    state machine by commenting each state and by laying out the functions
    implementing each state in the order that each state is normally
    executed (in the absence of errors).
    
    The previous patch "Fix null dereference in call_allocate" changed the
    order of the states.  Move the functions and update the comments to
    reflect the change.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 006abe887c5e637d059c44310de6c92f36aded3b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 12 19:55:25 2010 -0400

    SUNRPC: Fix a race in rpc_info_open
    
    There is a race between rpc_info_open and rpc_release_client()
    in that nothing stops a process from opening the file after
    the clnt->cl_kref goes to zero.
    
    Fix this by using atomic_inc_unless_zero()...
    
    Reported-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 5a67657a2e90c9e4a48518f95d4ba7777aa20fbb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 12 19:55:25 2010 -0400

    SUNRPC: Fix race corrupting rpc upcall
    
    If rpc_queue_upcall() adds a new upcall to the rpci->pipe list just
    after rpc_pipe_release calls rpc_purge_list(), but before it calls
    gss_pipe_release (as rpci->ops->release_pipe(inode)), then the latter
    will free a message without deleting it from the rpci->pipe list.
    
    We will be left with a freed object on the rpc->pipe list.  Most
    frequent symptoms are kernel crashes in rpc.gssd system calls on the
    pipe in question.
    
    Reported-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit f2d47d02fd84343a3c5452daca6ed12c75618aff
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Sep 12 19:55:25 2010 -0400

    Fix null dereference in call_allocate
    
    In call_allocate we need to reach the auth in order to factor au_cslack
    into the allocation.
    
    As of a17c2153d2e271b0cbacae9bed83b0eaa41db7e1 "SUNRPC: Move the bound
    cred to struct rpc_rqst", call_allocate attempts to do this by
    dereferencing tk_client->cl_auth, however this is not guaranteed to be
    defined--cl_auth can be zero in the case of gss context destruction (see
    rpc_free_auth).
    
    Reorder the client state machine to bind credentials before allocating,
    so that we can instead reach the auth through the cred.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org



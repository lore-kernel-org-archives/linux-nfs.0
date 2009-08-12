Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Subject: [PATCH 0/7] nfsd: add support for NFSv4 callbacks over IPv6 (try #4)
Date: Wed, 12 Aug 2009 07:56:59 -0400
Message-Id: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Fourth attempt at a patchset to add support for NFSv4 callbacks over
IPv6. Changes from last patchset include:

1) moved address copy and comparison routines to net/sunrpc/addr.c and
wrapped them properly in #ifdef's. Also changed lockd to use the common
routines instead of its own.

2) added back in support for handling scope-id's (for when a host mounts
a link-local address.

Tested using opensolaris and linux and verifying that delegations could
be properly recalled. I also tested mounts to the server's link-local
address and verified that the callback channel connected correctly.

...the rest of the code is pretty much the same as the last set. This
patchset should apply cleanly to Bruce's tree as of a pull this morning.

Jeff Layton (7):
  sunrpc: add routine for comparing addresses
  sunrpc: add common routine for copying address portion of a sockaddr
  nfsd: convert nfs4_cb_conn struct to hold address in sockaddr_storage
  nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
  nfsd: convert gen_callback to use rpc_uaddr2sockaddr
  nfsd: add support for NFSv4 callbacks over IPv6
  nfsd: populate sin6_scope_id on callback address with scopeid from
    rq_addr on SETCLIENTID call

 fs/lockd/clntlock.c         |    2 +-
 fs/lockd/host.c             |    4 +-
 fs/lockd/mon.c              |    2 +-
 fs/lockd/svcsubs.c          |    2 +-
 fs/nfsd/nfs4callback.c      |   11 +---
 fs/nfsd/nfs4state.c         |  142 ++++++++++++++++---------------------------
 include/linux/lockd/lockd.h |   43 -------------
 include/linux/nfsd/state.h  |    6 +-
 include/linux/sunrpc/clnt.h |    3 +
 net/sunrpc/addr.c           |   98 +++++++++++++++++++++++++++++
 10 files changed, 163 insertions(+), 150 deletions(-)

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

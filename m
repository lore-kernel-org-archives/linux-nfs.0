Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, chuck.lever@oracle.com
Subject: [PATCH 0/6] nfsd: add support for NFSv4 callbacks over IPv6 (try #5)
Date: Fri, 14 Aug 2009 12:57:53 -0400
Message-Id: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
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

Fifth attempt at a patchset to add support for NFSv4 callbacks over
IPv6. Changes from last patchset are mostly to address Chuck's comments:

1) made the new address comparison and copy routines into static inlines
and added them to clnt.h. Ditto for the get_scope_id function.

2) combined the patch to change nfs4_cb_conn to hold address in
sockaddr_storage with the one to convert gen_callback to use
rpc_uaddr2sockaddr. That eliminates changes to the parse_ipv4 function
that eventually gets ripped out.

Tested using opensolaris and linux and verifying that delegations could
be properly recalled. I also tested mounts to the server's link-local
address and verified that the callback channel connected correctly.

Jeff Layton (6):
  sunrpc: add routine for comparing addresses
  sunrpc: add common routine for copying address portion of a sockaddr
  nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
  nfsd: convert nfs4_cb_conn struct to hold address in sockaddr_storage
  nfsd: add support for NFSv4 callbacks over IPv6
  nfsd: populate sin6_scope_id on callback address with scopeid from
    rq_addr on SETCLIENTID call

 fs/lockd/clntlock.c         |    2 +-
 fs/lockd/host.c             |    4 +-
 fs/lockd/mon.c              |    2 +-
 fs/lockd/svcsubs.c          |    2 +-
 fs/nfsd/nfs4callback.c      |   11 +---
 fs/nfsd/nfs4state.c         |  133 ++++++++++++++-----------------------------
 include/linux/lockd/lockd.h |   43 --------------
 include/linux/nfsd/state.h  |    6 +-
 include/linux/sunrpc/clnt.h |  113 ++++++++++++++++++++++++++++++++++++
 9 files changed, 166 insertions(+), 150 deletions(-)

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

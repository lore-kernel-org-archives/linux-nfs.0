From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] nfs-utils: convert gssd to TI-RPC and add IPv6 support
	(try #4)
Date: Tue,  7 Apr 2009 11:25:41 -0400
Message-ID: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the fourth attempt at adding support for IPv6 to
rpc.gssd. The main change from the last set is that this one now uses a
rpcbind query to determine the server's port rather than doing a
getaddrinfo call to query the local services db.

The series should be fully bisectable, but I've only really tested the
end result for anything other than to see if it compiles. With these
patches I've been able to mount an OpenSolaris server using NFSv3/4 +
IPv6 + krb5 auth. I've also done testing with builds with only TIRPC
enabled and with TIRPC and IPv6 both disabled and haven't seen any
regressions.

List of changes since the last set:
- use rpcbind query to determine port for RPC client
- added comment explaining gssd doesn't deal with IPv6 scope_id's
- slight cleanups and clarifications to comments
- properly handle EAI_SYSTEM return code from  getnameinfo() call
- changed autoconf check for getnameinfo to check whenever --enable-gss
  is set, not just when NFSv4 is also enabled.

Jeff Layton (5):
  nfs-utils: make getnameinfo() required for --enable-gss
  nfs-utils: store the address given in the upcall for later use
  nfs-utils: query for remote port using rpcbind instead of getaddrinfo
  nfs-utils: switch gssd to use standard function for getting an RPC
    client
  nfs-utils: add IPv6 code to gssd

 configure.ac           |    3 +
 utils/gssd/gssd.h      |    2 +-
 utils/gssd/gssd_proc.c |  286 +++++++++++++++++++++++++++++++++---------------
 3 files changed, 204 insertions(+), 87 deletions(-)

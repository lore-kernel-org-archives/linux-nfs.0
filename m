Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Subject: [PATCH 0/4] sunrpc/nfs: better handling for expired krb5 credentials
Date: Thu,  7 Jan 2010 09:42:01 -0500
Message-Id: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
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

When someone deploys kerberized NFS, they usually will quickly run
across a major problem. As soon as their credentials expire, all RPCs
start failing with -EACCES errors. This makes it really difficult to
have any sort of long-running job since you have to proactively kinit
before your TGT expires. If you miss doing so, then your job may start
getting errors unexpectedly.

This patchset represents a first pass at fixing this. The idea here is
to distinguish between the situation where someone has an expired
credential cache and someone that has no credential cache at all. In the
latter case, we want to have the RPC return -EACCES (just like it does
today), in the former case we want to return a different error that will
make the NFS layer delay and retry the call instead of erroring out
(-EKEYEXPIRED).

This patchset is for the kernel patches. To make this work, gssd will
also need to be fixed to send different errors in these situations. That
patch will follow this set.

Jeff Layton (4):
  sunrpc: parse and return errors reported by gssd
  nfs4: handle -EKEYEXPIRED errors from RPC layer
  nfs: handle NFSv3 -EKEYEXPIRED errors as we would -EJUKEBOX
  nfs: handle NFSv2 -EKEYEXPIRED returns from RPC layer appropriately

 fs/nfs/nfs3proc.c              |    9 ++++---
 fs/nfs/nfs4proc.c              |   11 ++++++++-
 fs/nfs/nfs4state.c             |    1 +
 fs/nfs/proc.c                  |   41 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |   11 ++++++++-
 5 files changed, 65 insertions(+), 8 deletions(-)

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] nfsd/dlm: fix knfsd panic when NFSv4
	client does GETLK call on GFS2 (regression)
Date: Wed, 21 Jan 2009 11:34:49 -0500
Message-ID: <1232555691-29859-1-git-send-email-jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: lkml@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

This patchset fixes a regression due to this patch:

----------------[snip]----------------
commit 55ef1274dddd4de387c54d110e354ffbb6cdc706
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sat Dec 20 11:58:38 2008 -0800

    nfsd: Ensure nfsv4 calls the underlying filesystem on LOCKT
----------------[snip]----------------

To reproduce, set up a nfs server that is serving out a GFS2 filesystem.
Set a lock locally on a file on the GFS2 export on the server. From a
NFSv4 client, do a GETLK against the same file. The server will oops due
to a NULL pointer dereference. The fl_lmops will be set, but the
fl_owner will be a NULL pointer. The knfsd code does not account for
this possibility. It assumes that when fl_lmops is set this way that
the fl_owner will point to a valid nfs4_stateowner struct.

In actuality, Bruce's patch is correct, but it exposes a bug in DLM's
GETLK codepath. The first patch in this set fixes that.

The second patch fixes knfsd to be a little more careful about the
file_lock struct it builds to pass to vfs_test_lock.

Either patch should prevent the panic, though I think applying both
patches is the best approach to fixing this.

Jeff Layton (2):
  dlm: initialize file_lock struct in GETLK before copying conflicting
    lock
  nfsd: only set file_lock.fl_lmops in nfsd4_lockt if a stateowner is
    found

 fs/dlm/plock.c      |    2 ++
 fs/nfsd/nfs4state.c |    6 ++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

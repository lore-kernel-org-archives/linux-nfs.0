Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Fri, 25 Apr 2008 13:57:13 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: more nfsd changes for 2.6.26
Message-ID: <20080425175713.GA1057@fieldses.org>
References: <20080423213337.GG8302@fieldses.org>
In-Reply-To: <20080423213337.GG8302@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        linux-kernel@vger.kernel.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
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

A few more nfsd-related changes are available in the git repository at:

	git://linux-nfs.org/~bfields/linux.git for-linus

Mainly this adds a couple new interfaces from Wendy Cheng which allow
userland to tell the nfs server to drop locks held on a given filesystem
(or held by clients accessing the server via a given server ip address),
helpful in high-availability setups when taking down a server whose job
is being taken over by another.

(This could have probably gone with the first pull request, but the
patches were still getting a little work--a small bugfix, and some
fiddling with function names and such.)

The rest are miscellaneous minor bugfixes and cleanup.

--b.

David M. Richter (4):
      leases: fix a return-value mixup
      leases: when unlocking, skip locking-related steps
      leases: move lock allocation earlier in generic_setlease()
      leases: remove unneeded variable from fcntl_setlease().

J. Bruce Fields (2):
      locks: don't call ->copy_lock methods on return of conflicting locks
      nfsd: don't allow setting ctime over v4

James Lentini (1):
      Update to NFS/RDMA documentation

Wendy Cheng (2):
      lockd: unlock lockd locks associated with a given server ip
      lockd: unlock lockd locks held for a certain filesystem

 Documentation/filesystems/nfs-rdma.txt |   14 ++++--
 fs/lockd/svclock.c                     |    2 +-
 fs/lockd/svcsubs.c                     |   69 ++++++++++++++++++++++++++++----
 fs/locks.c                             |   32 ++++++++-------
 fs/nfsd/nfs4state.c                    |    3 -
 fs/nfsd/nfs4xdr.c                      |   14 ------
 fs/nfsd/nfsctl.c                       |   65 ++++++++++++++++++++++++++++++
 include/linux/fs.h                     |    1 +
 include/linux/lockd/lockd.h            |    8 +++-
 include/linux/nfsd/nfsd.h              |    2 +-
 10 files changed, 162 insertions(+), 48 deletions(-)

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

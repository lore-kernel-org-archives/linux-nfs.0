From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: New NFS_ALL client patches for 2.6.16-rc4...
Date: Sat, 25 Feb 2006 15:55:31 -0500
Message-ID: <1140900931.7875.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

See

  http://client.linux-nfs.org/Linux-2.6.x/2.6.16-rc4/

This patchset fixes a few regressions that were observed in the last
CITI patch: linux-2.6.16-rc4-CITI_NFS4_ALL-1.dif.

The main change is a fix to the generic VFS locking code: an incorrect
copy of the lock private area meant that the NFSv2/v3 locking code was
Oopsing when Christoph Hellwig's code cleanup "lockd: stop abusing
file_lock_list" was applied.

In addition, there are a few extra cleanups and a fix for the problem
that a user call to the utimes() function (sets the mtime/atime) could
be clobbered if there were cached writes.

Cheers,
  Trond

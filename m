From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 0/6] Client support for crossing NFS server mountpoints
Date: Tue, 11 Apr 2006 13:45:43 -0400
Message-ID: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: linux-fsdevel@vger.kernel.org
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

The following series of patches implement NFS client support for crossing
server submounts (assuming that the server is exporting them using the
'nohide' option).  We wish to ensure that inode numbers remain unique
on either side of the mountpoint, so that programs like 'tar' and
'rsync' do not get confused when confronted with files that have the same
inode number, but are actually on different filesystems on the server.

This is achieved by having the client automatically create a submount
that mirrors the one on the server.

In order to avoid confusing users, we would like for this mountpoint to b=
e
transparent to 'umount': IOW: when the user mounts the filesystem '/foo',
then an automatic submount by the NFS client for /foo/bar should not caus=
e
'umount /foo' (particularly since the kernel cannot create entries for
/foo/bar in /etc/mtab). To get around this we mark automatically
created submounts using the new flag MNT_SHRINKABLE, and then allow
the NFS client to attempt to unmount them whenever the user calls umount =
on
the parent.

Note: This code also serves as the base for NFSv4 'referral' support, in
which one server may direct the client to a different server as it crosse=
s
into a filesystem that has been migrated.

Cheers,
  Trond

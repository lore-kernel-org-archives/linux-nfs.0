From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: NFS client updates for 2.6.20...
Date: Tue, 05 Dec 2006 20:37:00 -0500
Message-ID: <1165369020.5731.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
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

There is a new NFS_ALL available from

	http://client.linux-nfs.org/Linux-2.6.x/2.6.19/

This one contains mainly bugfixes, including some significant changes to
the NFS page write code, the latter being in order to realign NFS with
the locking rules for the 2.6 VM/MM layer.
In particular, note that the legacy synchronous write code that was only
used if you used 'mount -osync' has been dropped, and replaced with the
regular O_SYNC write code.

Enjoy,
  Trond

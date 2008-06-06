From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] Convert knfsd to kthread API and fix startup/shutdown
	races (try #3)
Date: Fri,  6 Jun 2008 11:12:46 -0400
Message-ID: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: bfields@fieldses.org
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

This patchset is the third attempt to change nfsd to the kthread
API. Most of the changes here were suggested by Greg Banks. The main
changes from the second patchset are:

- add more stringent locking around some of the /proc/fs/nfsd
  interfaces. Particularly those that set parameters that are only
  consulted when nfsd is starting.

- I've also changed more of these interfaces to return -EBUSY when
  someone attempts to set them while nfsd is up.

- fixed /proc/fs/nfsd/nfsv4recoverydir to return the recoverydir
  pathname when read. It previously always returned -EINVAL.

- removed the sv_kill_signal parameter from svc_serv struct, and
  changed svc_set_pool_threads to send SIGINT to bring down a thread.

As always, comments and suggestions are appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

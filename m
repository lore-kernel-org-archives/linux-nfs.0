From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/4] Convert knfsd to kthread API and fix startup/shutdown
	races (try #2)
Date: Wed,  4 Jun 2008 11:03:12 -0400
Message-ID: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: gnb@melbourne.sgi.com
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

This patchset is the second attempt to change nfsd to the kthread
API. The main changes from the first patchset are:

- it includes the patch by Neil Brown to take the BKL out of nfsd
  startup/shutdown codepath. This should hopefully plug the main
  race condition that could lead to oopses when nfsd was signaled
  and then rapidly restarted before all of the existing nfsd's had
  gone down. I've also added some comments to this patch to try
  and clarify the locking for future work.

- It preserves signaling as the main method for taking down nfsd.
  While kthread_stop is easier to deal with and less racy than
  signals, a lot of distros do the equivalent of "pkill nfsd" to
  take nfsd down. Changing that would be painful. Also, using
  kthread_stop is slower than using signals, since taking down
  each thread would be serialized.

- it removes the special handling where if the last thread caught a
  SIGHUP, the kernel would leave the export cache intact

I've tested this by running I/O against the server w/ iozone while
restarting nfs service in a loop. Everything seems to work as expected.

As always, comments and suggestions are appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

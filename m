From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] fix potential races in lockd and nfs4-callback
	startup/shutdown
Date: Wed, 11 Jun 2008 10:03:09 -0400
Message-ID: <1213192992-7635-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
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

As Trond Myklebust pointed out, the current kthread-based lockd and
nfsv4 callback threads have a race condition if they are started and
brought down very rapidly. If this occurs, there is a chance that the
main thread function will never be run, and the cleanup done when the
function exits will not occur. This patchset fixes this by moving the
cleanup into the respective *_down functions.

While Bruce has just taken in a patchset from me to change nfsd to
kthreads, this race doesn't seem to exist there. We aren't using
kthread_stop() to take down nfsd, only signals, so I don't think the
kthread can be stopped before nfsd() actually runs.

The set also includes a patch to remove the BKL from nfs_callback_up
and nfs_callback_down.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

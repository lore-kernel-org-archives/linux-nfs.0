From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/7] Intro: convert lockd to kthread and fix use-after-free
	(try #3)
Date: Tue, 18 Dec 2007 15:19:35 -0500
Message-ID: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org
To: linux-nfs@vger.kernel.org
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

This is the third patchset to fix the use-after-free problem in lockd,
and to convert lockd to use the kthread API instead of kernel_thread.
The main change from the last patchset is the elimination of the
svc_create_kthread helper function, and having lockd_up call kthread_run
directly. I've also made some changes to the function prototype for
the lockd function to eliminate the need for casting the function
pointer.

Tested against the reproducer I have for the main issue (detailed in
patch #7). As always, comments and suggestions are appreciated.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

From: Michal Schmidt <mschmidt@redhat.com>
Subject: interrupting the wait for NLM GRANT causes problems
Date: Thu, 13 Mar 2008 19:32:26 +0100
Message-ID: <20080313193226.4cf9100e@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/MROv7JZOJF7NJDVn0KIYD6d"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbYCMScq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 14:32:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/MROv7JZOJF7NJDVn0KIYD6d
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

[CC Jeff, I found your bz432855 where you noticed the same problem]

Hello,

When a client attempting to lock a file and waiting for NLM
GRANTED callback is interrupted by a signal in nlmclnt_block(), bad
things happen.

The userspace program will get EINTR and most likely retry the lock,
which it can successfully obtain (when the GRANTED callback comes).
That sounds OK, but something causes the client to lose track of this
lock and when the program tries to release the lock, the NLM UNLOCK
message is sent with a new SVID. The NFS server rightfully thinks
the file is still locked by the original SVID. Noone can lock the file
again.

I think the bug is in do_setlk(), where the VFS lock is created when
the lock attempt was interrupted by a signal. I don't understand the
reason why it does that. nlmclnt_lock() cancels the lock request if
nlmclnt_block() is interrupted, so there should be no state on the
server to be cleaned (as the comment suggests there is). But I may be
missing something.

Attached is a test program. It locks a file and waits for Enter before
unlocking it. It shows the locks held at the interesting moments
(from /proc/locks).

To reproduce the bug, run the program on two clients at the same time:
./lockunlock /mnt/nfs_server/shared_file

The first client will get the lock. Press CTRL+C on the second one, to
interrupt its wait for NLM GRANTED. Notice the VFS lock shown. Press
Enter on the first client, to release the lock. The second client will
obtain it. Let it release it. Try running it again and notice you can't
lock the file anymore.

I have tried the following patch and it helps in my testcase. But maybe
it breaks something else?

Comments welcome.

Michal


---
 fs/nfs/file.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ef57a5a..b311d9a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -572,17 +572,9 @@ static int do_setlk(struct file *filp, int cmd,
struct file_lock *fl) 
 	lock_kernel();
 	/* Use local locking if mounted with "-onolock" */
-	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)) {
+	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
-		/* If we were signalled we still need to ensure that
-		 * we clean up any state on the server. We therefore
-		 * record the lock call as having succeeded in order to
-		 * ensure that locks_remove_posix() cleans it out when
-		 * the process exits.
-		 */
-		if (status == -EINTR || status == -ERESTARTSYS)
-			do_vfs_lock(filp, fl);
-	} else
+	else
 		status = do_vfs_lock(filp, fl);
 	unlock_kernel();
 	if (status < 0)
-- 
1.5.3.6


--MP_/MROv7JZOJF7NJDVn0KIYD6d
Content-Type: text/x-csrc; name=lockunlock.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=lockunlock.c

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <errno.h>

static void inthandler(int signum)
{
	/* nothing */
}

static void show_my_locks(void)
{
	char command[100];
	sprintf(command, "grep -E '^([[:graph:]]+[[:space:]]+){4}%d' < /proc/locks", getpid());
	printf("My locks:\n");
	system(command);
	printf("---\n");
}

int main(int argc, char *argv[])
{
	int f,err;
	struct flock lock;
	sigset_t ss;
	struct sigaction sa;

	if (argc != 2) {
		printf("Usage: lockunlock <filename>\n");
		return 1;
	}
	f = open(argv[1], O_RDWR);
	if (f < 0) {
		perror("open");
		return 2;
	}

	sigemptyset(&ss);
	sa.sa_handler = inthandler;
	sa.sa_mask = ss;
	sa.sa_flags = 0;
	sigaction(SIGINT, &sa, NULL);

	show_my_locks();

	printf("Trying to lock the file...\n");

	for (;;) {
		lock.l_type = F_WRLCK;
		lock.l_whence = SEEK_SET;
		lock.l_start = 0;
		lock.l_len = 1;
		err = fcntl(f, F_SETLKW, &lock);
		if (!err)
			break;
		if (errno == EINTR) {
			printf("Interrupted by a signal. I should have no lock here:\n");
			show_my_locks();
			printf("Retrying...\n");
		} else {
			perror("F_SELKW");
			return 3;
		}
	}

	printf("Locked.\n");
	show_my_locks();

	printf("Press ENTER to unlock.\n");
	getchar();

	printf("Unlocking...\n");

	lock.l_type = F_UNLCK;
	lock.l_whence = SEEK_SET;
	lock.l_start = 0;
	lock.l_len = 1;
	err = fcntl(f, F_SETLKW, &lock);
	if (err < 0) {
		perror("F_SELKW");
		return 3;
	}

	printf("Unlocked.\n");
	show_my_locks();

	close(f);
	return 0;
}

--MP_/MROv7JZOJF7NJDVn0KIYD6d--

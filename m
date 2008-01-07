From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 2/2] Fix lockd panic
Date: Mon, 07 Jan 2008 00:53:54 -0500
Message-ID: <4781BE72.7050404@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070906060800040406050701"
Cc: cluster-devel@redhat.com
To: NFS list <linux-nfs@vger.kernel.org>
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

This is a multi-part message in MIME format.
--------------070906060800040406050701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This small patch has not been changed since our last discussion:
http://www.opensubscriber.com/message/nfs@lists.sourceforge.net/6348912.html

To recap the issue, a client could ask for a posix lock that invokes:

 >>>     server calls nlm4svc_proc_lock() ->
 >>>         * server lookup file (f_count++)
 >>>         * server lock the file
 >>>         * server calls nlm_release_host
 >>>         * server calls nlm_release_file (f_count--)
 >>>         * server return to client with status 0
 >>>

As part of the lookup file, the lock stays on vfs inode->i_flock list 
with zero f_count. Any call into nlm_traverse_files() will BUG() in 
locks_remove_flock() (fs/locks.c:2034) during fclose(), if that file 
happens to be of no interest to that particular search. Since after 
nlm_inspect_file(), the logic unconditionally checks for possible 
removing of the file. As the file is not blocked, nothing to do with 
shares, and f_count is zero, it will get removed from hash and fclose() 
invoked with the posix lock hanging on i_flock list.

-- Wendy


--------------070906060800040406050701
Content-Type: text/x-patch;
 name="unlock_002.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="unlock_002.patch"

This fixes the incorrect fclose call inside nlm_traverse_files() where
a posix lock could still be held by NFS client. Problem was found in a
kernel panic inside locks_remove_flock() (fs/locks.c:2034) as part of
the fclose call due to NFS-NLM locks still hanging on inode->i_flock list.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>

 svcsubs.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

--- linux-nlm-1/fs/lockd/svcsubs.c	2008-01-06 18:23:20.000000000 -0500
+++ linux/fs/lockd/svcsubs.c	2008-01-06 18:24:12.000000000 -0500
@@ -332,8 +332,7 @@ nlm_traverse_files(struct nlm_host *host
 			mutex_lock(&nlm_file_mutex);
 			file->f_count--;
 			/* No more references to this file. Let go of it. */
-			if (list_empty(&file->f_blocks) && !file->f_locks
-			 && !file->f_shares && !file->f_count) {
+			if (!nlm_file_inuse(file)) {
 				hlist_del(&file->f_list);
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);

--------------070906060800040406050701--

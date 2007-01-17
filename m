From: Jeffrey Layton <jlayton@redhat.com>
Subject: Re: CVE-2006-5158 -- is a NULL
	nfs_lockowner->owner	field	legal?
Date: Wed, 17 Jan 2007 13:54:17 -0500
Message-ID: <200701171854.l0HIsHxO026388@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: staubach@redhat.com, nfs@lists.sourceforge.net,
	Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7Fx3-0005HX-QI
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 10:56:01 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H7Fvo-0005Iq-Lk
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 10:56:03 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trond Myklebust wrote:
> On Wed, 2007-01-17 at 11:39 -0500, Jeff Layton wrote:
>> I've been looking over an issue that related to CVE-2006-5158 (which is a
>> NULL pointer dereference in nlmclnt_mark_reclaim). It looks like the only
>> way it's possible to get in this situation is when the kmalloc in
>> nlm_find_lockowner returns NULL. If this occurs, it seems like that should
>> be an error condition and we should abort whatever operation is occurring.
>>
>> So my question is -- should a NULL "owner" field in an nfs_lockowner struct
>> even be considered legal? If not, would something like the patch below be
>> reasonable?
> 
> No. NULL owner fields are not legal, and we should indeed abort the lock
> call whenever that occurs.
> 
> Cheers,
>   Trond
> 

Ok. I think this patch is probably a cleaner approach. I've not tested it, but
it looks like it'll do the right thing. Look ok?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 0b4acc1..9c8675f 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -28,7 +28,7 @@ static int	nlmclnt_test(struct nlm_rqst *, struct file_lock *);
 static int	nlmclnt_lock(struct nlm_rqst *, struct file_lock *);
 static int	nlmclnt_unlock(struct nlm_rqst *, struct file_lock *);
 static int	nlm_stat_to_errno(__be32 stat);
-static void	nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host);
+static int	nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host);
 static int	nlmclnt_cancel(struct nlm_host *, int , struct file_lock *);
 
 static const struct rpc_call_ops nlmclnt_unlock_ops;
@@ -178,7 +178,12 @@ nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
 	if (call == NULL)
 		return -ENOMEM;
 
-	nlmclnt_locks_init_private(fl, host);
+	status = nlmclnt_locks_init_private(fl, host);
+	if (status) {
+		nlm_release_call(call);
+		return status;
+	}
+
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
 
@@ -449,13 +454,16 @@ static struct file_lock_operations nlmclnt_lock_ops = {
 	.fl_release_private = nlmclnt_locks_release_private,
 };
 
-static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host)
+static int nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host)
 {
 	BUG_ON(fl->fl_ops != NULL);
 	fl->fl_u.nfs_fl.state = 0;
 	fl->fl_u.nfs_fl.owner = nlm_find_lockowner(host, fl->fl_owner);
+	if (fl->fl_u.nfs_fl.owner == NULL)
+		return -ENOMEM;
 	INIT_LIST_HEAD(&fl->fl_u.nfs_fl.list);
 	fl->fl_ops = &nlmclnt_lock_ops;
+	return 0;
 }
 
 static int do_vfs_lock(struct file_lock *fl)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

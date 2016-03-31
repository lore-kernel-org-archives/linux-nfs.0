Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29531 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbcCaBGc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2016 21:06:32 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u2V16VgO010062
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 01:06:31 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id u2V16UBO016526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 01:06:31 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.13.8/8.13.8) with ESMTP id u2V16T7j007954
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 01:06:30 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFCv2] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160328211906.20739.10519.stgit@manet.1015granger.net>
Date: Wed, 30 Mar 2016 21:06:28 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FE201995-97F7-4E4B-956B-F2BACAC94B0B@oracle.com>
References: <20160328211906.20739.10519.stgit@manet.1015granger.net>
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 28, 2016, at 5:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> At Connectathon 2016, we found that recent upstream Linux clients
> would occasionally send a LOCK operation with a zero stateid. This
> appeared to happen in close proximity to another thread returning
> a delegation before unlinking the same file while it remained open.
> 
> Earlier, the client received a write delegation on this file and
> returned the open stateid. Now, as it is getting ready to unlink the
> file, it returns the write delegation. But there is still an open
> file descriptor on that file, so the client must OPEN the file
> again before it returns the delegation.
> 
> To eliminate this race, serialize delegation return with the
> acquisition of a file lock on the same file. Adopt the same approach
> as is used in the unlock path.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

I see two new behaviors when this patch is applied:

1. With NFSv4.0, the cthon04 lock test #7 hangs after
"unlock region so child will unblock". ^C then unmount
works as expected.

2. With NFSv4.0, xfstests generic/089 fails because one
of the three test processes is starved out of locking
the test file (t_mtab). The test fails, there are no
other hangs or error messages.

I'm starting to look into the first issue.


> fs/nfs/nfs4proc.c |    8 +++++++-
> 1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 01bef06..dd435f4 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6054,6 +6054,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
> static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
> {
> 	struct nfs_inode *nfsi = NFS_I(state->inode);
> +	struct nfs4_state_owner *sp = state->owner;
> 	unsigned char fl_flags = request->fl_flags;
> 	int status = -ENOLCK;
> 
> @@ -6065,9 +6066,12 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
> 	if (status != 0)
> 		goto out;
> 	request->fl_flags |= FL_ACCESS;
> +	mutex_lock(&sp->so_delegreturn_mutex);
> 	status = do_vfs_lock(state->inode, request);
> -	if (status < 0)
> +	if (status < 0) {
> +		mutex_unlock(&sp->so_delegreturn_mutex);
> 		goto out;
> +	}
> 	down_read(&nfsi->rwsem);
> 	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
> 		/* Yes: cache locks! */
> @@ -6075,9 +6079,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
> 		request->fl_flags = fl_flags & ~FL_SLEEP;
> 		status = do_vfs_lock(state->inode, request);
> 		up_read(&nfsi->rwsem);
> +		mutex_unlock(&sp->so_delegreturn_mutex);
> 		goto out;
> 	}
> 	up_read(&nfsi->rwsem);
> +	mutex_unlock(&sp->so_delegreturn_mutex);
> 	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
> out:
> 	request->fl_flags = fl_flags;
> 

--
Chuck Lever




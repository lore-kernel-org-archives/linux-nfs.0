Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32131 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbcCaQkP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2016 12:40:15 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u2VGeEj3017974
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 16:40:14 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id u2VGeDcg012411
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 16:40:14 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id u2VGeDMq024337
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 16:40:13 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFCv3] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160331163835.2791.6712.stgit@manet.1015granger.net>
Date: Thu, 31 Mar 2016 12:40:11 -0400
Message-Id: <DA3A049C-B497-4B61-A173-CE41BC9F49B7@oracle.com>
References: <20160331163835.2791.6712.stgit@manet.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 31, 2016, at 12:38 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
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
> Since commit 24311f884189 ('NFSv4: Recovery of recalled read
> delegations is broken'), nfs_open_delegation_recall() clears the
> NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
> racing LOCK on the same inode to be put on the wire before the OPEN
> operation has returned a valid open stateid.
> 
> To eliminate this race, serialize delegation return with the
> acquisition of a file lock on the same file. Adopt the same approach
> as is used in the unlock path.
> 
> Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ... ')
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

Previously reported issues have been addressed.


> fs/nfs/nfs4proc.c |    4 ++++
> 1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 01bef06..c40f1b6 100644
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
> @@ -6068,6 +6069,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
> 	status = do_vfs_lock(state->inode, request);
> 	if (status < 0)
> 		goto out;
> +	mutex_lock(&sp->so_delegreturn_mutex);
> 	down_read(&nfsi->rwsem);
> 	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
> 		/* Yes: cache locks! */
> @@ -6075,9 +6077,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28962 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359AbbHESoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 14:44:39 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t75IicEO024423
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Aug 2015 18:44:38 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t75IiboP023386
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Aug 2015 18:44:38 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t75IibTJ022336
	for <linux-nfs@vger.kernel.org>; Wed, 5 Aug 2015 18:44:37 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFS: Add OTW write barrier before may-open test
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150805182305.11796.75476.stgit@manet.1015granger.net>
Date: Wed, 5 Aug 2015 14:44:37 -0400
Message-Id: <359CCE70-6056-418F-B627-688BE27C7EA8@oracle.com>
References: <20150805182305.11796.75476.stgit@manet.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 5, 2015, at 2:34 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> Commit 14546c337588 ("NFS: Don't do a full flush to disk on close()
> if we hold a delegation") added an optimization. When an NFSv4 write
> delegation is present, close(2) does not wait while a file's dirty
> data is flushed to the NFS server.
> 
> However, if the application workload immediately re-opens that file,
> nfs_may_open() can perform an ACCESS and GETATTR which runs
> concurrently with the flushing WRITE. If the flushing WRITE and
> GETATTR complete out of order on the server, the file size cached on
> the client will go backwards, possibly resulting in new writes going
> to the wrong file offset.
> 
> Add a write barrier before the access check to ensure the server's
> idea of the file's size is properly up to date.
> 
> The downside of this approach is that each fresh open(2) of a dirty
> file results in an extra flush. It seems to me that _any_ open(2)
> done while there is dirty data waiting on the client could result in
> a file size roll back. However, I see bad behavior only when the
> client holds a write delegation.
> 
> Fixes: 14546c337588 ("NFS: Don't do a full flush to disk on . . .")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> fs/nfs/dir.c |    9 +++++++++
> 1 file changed, 9 insertions(+)
> 
> I'm not certain this is a good long term fix. Some other possible
> solutions include:
> 
> - Not performing the access check if the client holds a delegation
> - Not performing a GETATTR as part of the ACCESS check
> - Simply marking the file attributes stale instead of using the
>   returned file size
> - Reverting commit 14546c337588

OK. If the client holds a write delegation, then it shouldn't care
about the server's file size at all until it has flushed all dirty
data and returned the delegation. So flushing here is probably wrong.

But the incoming file size in the GETATTR is definitely screwing up
the cached file size.


> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 547308a..7b36993 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2439,6 +2439,15 @@ static int nfs_open_permission_mask(int openflags)
> 
> int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
> {
> +	/*
> +	 * If a write delegation is present, close(2) does not wait after
> +	 * flushing dirty data. Wait for write completion here to ensure
> +	 * the file size on the server is up to date. Otherwise this
> +	 * access check will roll back the cached file size.
> +	 */
> +	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
> +		nfs_sync_inode(inode);
> +
> 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
> }
> EXPORT_SYMBOL_GPL(nfs_may_open);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




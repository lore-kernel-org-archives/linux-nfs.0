Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:60318 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933158Ab3CSR3k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 13:29:40 -0400
Received: from vmwexceht05-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r2JHTd0T003889
	for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 10:29:39 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Date: Tue, 19 Mar 2013 17:29:37 +0000
Message-ID: <A0468A45-044E-45E1-8256-38AD5814B6D8@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond

You need to declare the new NFS_OPEN_CLAIMs.

From: Andy Adamson <andros@netapp.com>
Date: Tue, 19 Mar 2013 13:03:36 -0400
Subject: [PATCH 17/21] NFSv4.1 declare new NFS4_OPEN_CLAIM * FH

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs4.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7552bb5..380d944 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -388,7 +388,10 @@ enum open_claim_type4 {
        NFS4_OPEN_CLAIM_NULL = 0,
        NFS4_OPEN_CLAIM_PREVIOUS = 1,
        NFS4_OPEN_CLAIM_DELEGATE_CUR = 2,
-       NFS4_OPEN_CLAIM_DELEGATE_PREV = 3
+       NFS4_OPEN_CLAIM_DELEGATE_PREV = 3,
+       NFS4_OPEN_CLAIM_FH = 4,
+       NFS4_OPEN_CLAIM_DELEG_CUR_FH = 5,
+       NFS4_OPEN_CLAIM_DELEG_PREV_FH = 6
 };

 enum opentype4 {

-->Andy

On Mar 19, 2013, at 9:07 AM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Sometimes, we actually _want_ to do open-by-filehandle, for instance
> when recovering opens after a network partition, or when called
> from nfs4_file_open.
> Enable that functionality using a new capability NFS_CAP_ATOMIC_OPEN_V1,
> and which is only enabled for NFSv4.1 servers that support it.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/dir.c              |  2 ++
> fs/nfs/nfs4proc.c         | 53 ++++++++++++++++++++++++++++++++++++++++-------
> include/linux/nfs_fs_sb.h |  1 +
> 3 files changed, 49 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index f23f455..e093e73 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1486,6 +1486,8 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
> 		goto no_open;
> 	if (d_mountpoint(dentry))
> 		goto no_open;
> +	if (NFS_SB(dentry->d_sb)->caps & NFS_CAP_ATOMIC_OPEN_V1)
> +		goto no_open;
> 
> 	inode = dentry->d_inode;
> 	parent = dget_parent(dentry);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 712eb70..480b5d0 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -767,6 +767,35 @@ struct nfs4_opendata {
> 	int cancelled;
> };
> 
> +static bool nfs4_clear_cap_atomic_open_v1(struct nfs_server *server,
> +		int err, struct nfs4_exception *exception)
> +{
> +	if (err != -EINVAL)
> +		return false;
> +	if (!(server->caps & NFS_CAP_ATOMIC_OPEN_V1))
> +		return false;
> +	server->caps &= ~NFS_CAP_ATOMIC_OPEN_V1;
> +	exception->retry = 1;
> +	return true;
> +}
> +
> +static enum open_claim_type4
> +nfs4_map_atomic_open_claim(struct nfs_server *server,
> +		enum open_claim_type4 claim)
> +{
> +	if (server->caps & NFS_CAP_ATOMIC_OPEN_V1)
> +		return claim;
> +	switch (claim) {
> +	default:
> +		return claim;
> +	case NFS4_OPEN_CLAIM_FH:
> +		return NFS4_OPEN_CLAIM_NULL;
> +	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
> +		return NFS4_OPEN_CLAIM_DELEGATE_CUR;
> +	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
> +		return NFS4_OPEN_CLAIM_DELEGATE_PREV;
> +	}
> +}
> 
> static void nfs4_init_opendata_res(struct nfs4_opendata *p)
> {
> @@ -818,8 +847,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
> 	p->o_arg.server = server;
> 	p->o_arg.bitmask = server->attr_bitmask;
> 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
> -	p->o_arg.claim = claim;
> -	switch (claim) {
> +	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
> +	switch (p->o_arg.claim) {
> 	case NFS4_OPEN_CLAIM_NULL:
> 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
> 	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
> @@ -1326,6 +1355,8 @@ static int nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
> 	int err;
> 	do {
> 		err = _nfs4_do_open_reclaim(ctx, state);
> +		if (nfs4_clear_cap_atomic_open_v1(server, err, &exception))
> +			continue;
> 		if (err != -NFS4ERR_DELAY)
> 			break;
> 		nfs4_handle_exception(server, err, &exception);
> @@ -1741,7 +1772,7 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
> 	int ret;
> 
> 	opendata = nfs4_open_recoverdata_alloc(ctx, state,
> -			NFS4_OPEN_CLAIM_NULL);
> +			NFS4_OPEN_CLAIM_FH);
> 	if (IS_ERR(opendata))
> 		return PTR_ERR(opendata);
> 	ret = nfs4_open_recover(opendata, state);
> @@ -1759,6 +1790,8 @@ static int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4_state
> 
> 	do {
> 		err = _nfs4_open_expired(ctx, state);
> +		if (nfs4_clear_cap_atomic_open_v1(server, err, &exception))
> +			continue;
> 		switch (err) {
> 		default:
> 			goto out;
> @@ -1926,6 +1959,7 @@ static int _nfs4_do_open(struct inode *dir,
> 	struct nfs4_state     *state = NULL;
> 	struct nfs_server       *server = NFS_SERVER(dir);
> 	struct nfs4_opendata *opendata;
> +	enum open_claim_type4 claim = NFS4_OPEN_CLAIM_NULL;
> 	int status;
> 
> 	/* Protect against reboot recovery conflicts */
> @@ -1941,9 +1975,10 @@ static int _nfs4_do_open(struct inode *dir,
> 	if (dentry->d_inode != NULL)
> 		nfs4_return_incompatible_delegation(dentry->d_inode, fmode);
> 	status = -ENOMEM;
> +	if (dentry->d_inode)
> +		claim = NFS4_OPEN_CLAIM_FH;
> 	opendata = nfs4_opendata_alloc(dentry, sp, fmode, flags, sattr,
> -			NFS4_OPEN_CLAIM_NULL,
> -			GFP_KERNEL);
> +			claim, GFP_KERNEL);
> 	if (opendata == NULL)
> 		goto err_put_state_owner;
> 
> @@ -2001,6 +2036,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
> 					struct rpc_cred *cred,
> 					struct nfs4_threshold **ctx_th)
> {
> +	struct nfs_server *server = NFS_SERVER(dir);
> 	struct nfs4_exception exception = { };
> 	struct nfs4_state *res;
> 	int status;
> @@ -2044,7 +2080,9 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
> 			exception.retry = 1;
> 			continue;
> 		}
> -		res = ERR_PTR(nfs4_handle_exception(NFS_SERVER(dir),
> +		if (nfs4_clear_cap_atomic_open_v1(server, status, &exception))
> +			continue;
> +		res = ERR_PTR(nfs4_handle_exception(server,
> 					status, &exception));
> 	} while (exception.retry);
> 	return res;
> @@ -6872,7 +6910,8 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
> 		| NFS_CAP_ATOMIC_OPEN
> 		| NFS_CAP_CHANGE_ATTR
> 		| NFS_CAP_POSIX_LOCK
> -		| NFS_CAP_STATEID_NFSV41,
> +		| NFS_CAP_STATEID_NFSV41
> +		| NFS_CAP_ATOMIC_OPEN_V1,
> 	.call_sync = nfs4_call_sync_sequence,
> 	.match_stateid = nfs41_match_stateid,
> 	.find_root_sec = nfs41_find_root_sec,
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 74c9e52..d8fdfdc 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -198,5 +198,6 @@ struct nfs_server {
> #define NFS_CAP_POSIX_LOCK	(1U << 14)
> #define NFS_CAP_UIDGID_NOMAP	(1U << 15)
> #define NFS_CAP_STATEID_NFSV41	(1U << 16)
> +#define NFS_CAP_ATOMIC_OPEN_V1	(1U << 17)
> 
> #endif
> -- 
> 1.8.1.4
> 


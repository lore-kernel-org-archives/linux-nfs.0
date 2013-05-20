Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16061 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756729Ab3ETTdC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 15:33:02 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 11/13] NFS: Client implementation of Labeled-NFS
Date: Mon, 20 May 2013 19:33:00 +0000
Message-ID: <1369078372.6115.34.camel@leira.trondhjem.org>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	 <1368719808-14584-12-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-12-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 11:56 -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> This patch implements the client transport and handling support for labeled
> NFS. The patch adds two functions to encode and decode the security label
> recommended attribute which makes use of the LSM hooks added earlier. It also
> adds code to grab the label from the file attribute structures and encode the
> label to be sent back to the server.
> 
> Acked-by: James Morris <james.l.morris@oracle.com>
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/inode.c            |  57 ++++++++-
>  fs/nfs/nfs4proc.c         | 304 ++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfs/nfs4xdr.c          | 164 +++++++++++++++++++------
>  fs/nfs/super.c            |  17 ++-
>  include/linux/nfs_fs.h    |   3 +
>  include/linux/nfs_fs_sb.h |   5 +
>  security/selinux/hooks.c  |   4 +
>  7 files changed, 496 insertions(+), 58 deletions(-)

<snip>
> +static int _nfs4_do_set_security_label(struct inode *inode,
> +		struct nfs4_label *ilabel,
> +		struct nfs_fattr *fattr,
> +		struct nfs4_label *olabel,
> +		struct nfs4_state *state)
> +{
> +
> +	struct iattr sattr = {0};
> +	struct nfs_server *server = NFS_SERVER(inode);
> +	const u32 bitmask[3] = { 0, 0, FATTR4_WORD2_SECURITY_LABEL };
> +	struct nfs_setattrargs args = {
> +		.fh             = NFS_FH(inode),
> +		.iap            = &sattr,
> +		.server		= server,
> +		.bitmask	= bitmask,
> +		.label		= ilabel,
> +	};
> +	struct nfs_setattrres res = {
> +		.fattr		= fattr,
> +		.label		= olabel,
> +		.server		= server,
> +	};
> +	struct rpc_message msg = {
> +		.rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
> +		.rpc_argp       = &args,
> +		.rpc_resp       = &res,
> +	};
> +	unsigned long timestamp = jiffies;
> +	int status;
> +
> +	if (state != NULL) {
> +		struct nfs_lockowner lockowner = {
> +			.l_owner = current->files,
> +			.l_pid = current->tgid,
> +		};
> +
> +		msg.rpc_cred = state->owner->so_cred;
> +		nfs4_select_rw_stateid(&args.stateid, state, FMODE_WRITE,
> +				&lockowner);
> +	} else if (nfs4_copy_delegation_stateid(&args.stateid, inode,
> +				FMODE_WRITE)) {
> +		/* Use that stateid */
> +	} else
> +		nfs4_stateid_copy(&args.stateid, &zero_stateid);

We don't need the open stateid here. Please just use the zero_stateid.

> +
> +	status = rpc_call_sync(server->client, &msg, 0);
> +	if (status == 0 && state != NULL)
> +		renew_lease(server, timestamp);
> +	return status;
> +}
> +
> +static int nfs4_do_set_security_label(struct inode *inode,
> +		struct nfs4_label *ilabel,
> +		struct nfs_fattr *fattr,
> +		struct nfs4_label *olabel,
> +		struct nfs4_state *state)
> +{
> +	struct nfs4_exception exception = { };
> +	int err;
> +
> +	do {
> +		err = nfs4_handle_exception(NFS_SERVER(inode),
> +				_nfs4_do_set_security_label(inode, ilabel,
> +				fattr, olabel, state),
> +				&exception);
> +	} while (exception.retry);
> +	return err;
> +}
> +
> +static int
> +nfs4_set_security_label(struct dentry *dentry, const void *buf, size_t buflen)
> +{
> +	struct nfs4_label ilabel, *olabel = NULL;
> +	struct nfs_fattr fattr;
> +	struct rpc_cred *cred;
> +	struct nfs_open_context *ctx;
> +	struct nfs4_state *state = NULL;
> +	struct inode *inode = dentry->d_inode;
> +	int status;
> +
> +	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
> +		return -EOPNOTSUPP;
> +
> +	nfs_fattr_init(&fattr);
> +
> +	ilabel.pi = 0;
> +	ilabel.lfs = 0;
> +	ilabel.label = (char *)buf;
> +	ilabel.len = buflen;
> +
> +	cred = rpc_lookup_cred();
> +	if (IS_ERR(cred))
> +		return PTR_ERR(cred);
> +
> +	olabel = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
> +	if (IS_ERR(olabel)) {
> +		status = -PTR_ERR(olabel);
> +		goto out;
> +	}
> +
> +	/* Search for an existing open(O_WRITE) file */
> +	ctx = nfs_find_open_context(inode, cred, FMODE_WRITE);
> +	if (ctx != NULL)
> +		state = ctx->state;


That also makes this code unnecessary.

> +
> +	status = nfs4_do_set_security_label(inode, &ilabel, &fattr, olabel,
> +						state);
> +	if (status == 0)
> +		nfs_setsecurity(inode, &fattr, olabel);
> +	if (ctx != NULL)
> +		put_nfs_open_context(ctx);
> +	nfs4_label_free(olabel);
> +out:
> +	put_rpccred(cred);
> +	return status;
> +}
> +#endif	/* CONFIG_NFS_V4_SECURITY_LABEL */
> +
> +

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

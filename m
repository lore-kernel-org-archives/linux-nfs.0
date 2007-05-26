From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 04/10] NFS: Fix up compiler warnings in super.c
Date: Sat, 26 May 2007 14:20:24 -0400
Message-ID: <1180203624.5517.14.camel@heimdal.trondhjem.org>
References: <20070525214115.28668.91905.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hs0st-00040f-OR
	for nfs@lists.sourceforge.net; Sat, 26 May 2007 11:21:02 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hs0sw-0002MB-Gn
	for nfs@lists.sourceforge.net; Sat, 26 May 2007 11:21:02 -0700
In-Reply-To: <20070525214115.28668.91905.stgit@schiele.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-25 at 17:41 -0400, Chuck Lever wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/super.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ca20d3c..79a07b5 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -263,11 +263,11 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
>  		{ RPC_AUTH_GSS_SPKM, "spkm" },
>  		{ RPC_AUTH_GSS_SPKMI, "spkmi" },
>  		{ RPC_AUTH_GSS_SPKMP, "spkmp" },
> -		{ -1, "unknown" }
> +		{ UINT_MAX, "unknown" }
>  	};
>  	int i;
>  
> -	for (i=0; sec_flavours[i].flavour != -1; i++) {
> +	for (i = 0; sec_flavours[i].flavour != UINT_MAX; i++) {
>  		if (sec_flavours[i].flavour == flavour)
>  			break;
>  	}
> @@ -355,7 +355,9 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
>  	int i, cpu;
>  	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
>  	struct rpc_auth *auth = nfss->client->cl_auth;
> -	struct nfs_iostats totals = { };
> +	struct nfs_iostats totals;
> +
> +	memset(&totals, 0, sizeof(struct nfs_iostats));

Urgh. What is the purpose of this?

>  	seq_printf(m, "statvers=%s", NFS_IOSTAT_VERS);
>  
> @@ -772,7 +774,7 @@ static void nfs4_fill_super(struct super_block *sb)
>  	nfs_initialise_sb(sb);
>  }
>  
> -static void *nfs_copy_user_string(char *dst, struct nfs_string *src, int maxlen)
> +static void *nfs_copy_user_string(char *dst, struct nfs_string *src, size_t maxlen)
>  {
>  	void *p = NULL;
>  
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

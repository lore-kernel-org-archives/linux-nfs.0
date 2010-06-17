From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 01/19] SQUASHME: pnfs-submit: merge pnfs4_proc_setattr
	into nfs4_proc_setattr
Date: Thu, 17 Jun 2010 11:00:45 -0400
Message-ID: <AANLkTika4BAGrDg0CnUPRy9Qji6rThr5zcZ0S8ciAr29@mail.gmail.com>
References: <4C1A3570.5030709@panasas.com>
	<1276786099-11300-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46764 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506Ab0FQPAr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:00:47 -0400
Received: by fxm10 with SMTP id 10so3523fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 08:00:45 -0700 (PDT)
In-Reply-To: <1276786099-11300-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 10:48 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> =A0fs/nfs/nfs4proc.c | =A0 35 +++++++++++++++--------------------
> =A01 files changed, 15 insertions(+), 20 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8c02296..17a2597 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2333,6 +2333,19 @@ static int nfs4_proc_getattr(struct nfs_server=
 *server, struct nfs_fh *fhandle,
> =A0 =A0 =A0 =A0return err;
> =A0}
>
> +static void
> +pnfs4_return_layout_on_setattr(struct inode *inode)
> +{
> +#ifdef CONFIG_NFS_V4_1
> + =A0 =A0 =A0 struct nfs_server *server =3D NFS_SERVER(inode);
> + =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(inode);
> +
> + =A0 =A0 =A0 if (pnfs_enabled_sb(server) && has_layout(nfsi) &&

pnfs_enabled_sb() is not needed given the following has_layout() test.

=46red

> + =A0 =A0 =A0 =A0 =A0 pnfs_ld_layoutret_on_setattr(server->pnfs_curr_=
ld))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout(inode, NULL, NULL, R=
ETURN_FILE, true);
> +#endif /* CONFIG_NFS_V4_1 */
> +}
> +
> =A0/*
> =A0* The file is not closed if it is opened due to the a request to c=
hange
> =A0* the size of the file. The open call will not be needed once the
> @@ -2359,6 +2372,8 @@ nfs4_proc_setattr(struct dentry *dentry, struct=
 nfs_fattr *fattr,
> =A0 =A0 =A0 =A0struct nfs4_state *state =3D NULL;
> =A0 =A0 =A0 =A0int status;
>
> + =A0 =A0 =A0 pnfs4_return_layout_on_setattr(inode);
> +
> =A0 =A0 =A0 =A0nfs_fattr_init(fattr);
>
> =A0 =A0 =A0 =A0/* Search for an existing open(O_WRITE) file */
> @@ -2378,25 +2393,6 @@ nfs4_proc_setattr(struct dentry *dentry, struc=
t nfs_fattr *fattr,
> =A0 =A0 =A0 =A0return status;
> =A0}
>
> -#ifdef CONFIG_NFS_V4_1
> -/*
> - * Return layout before issueing a setattr
> - */
> -static int
> -pnfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct iattr *sattr)
> -{
> - =A0 =A0 =A0 struct inode *inode =3D dentry->d_inode;
> - =A0 =A0 =A0 struct nfs_server *server =3D NFS_SERVER(inode);
> - =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(inode);
> -
> - =A0 =A0 =A0 if (pnfs_enabled_sb(server) && has_layout(nfsi) &&
> - =A0 =A0 =A0 =A0 =A0 pnfs_ld_layoutret_on_setattr(server->pnfs_curr_=
ld))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout(inode, NULL, NULL, R=
ETURN_FILE, true);
> - =A0 =A0 =A0 return nfs4_proc_setattr(dentry, fattr, sattr);
> -}
> -#endif /* CONFIG_NFS_V4_1 */
> -
> =A0static int _nfs4_proc_lookupfh(struct nfs_server *server, const st=
ruct nfs_fh *dirfh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct qstr *name, struct nfs_fh=
 *fhandle,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_fattr *fattr)
> @@ -6068,7 +6064,6 @@ pnfs_v4_clientops_init(void)
> =A0 =A0 =A0 =A0struct nfs_rpc_ops *p =3D (struct nfs_rpc_ops *)&pnfs_=
v4_clientops;
>
> =A0 =A0 =A0 =A0memcpy(p, &nfs_v4_clientops, sizeof(*p));
> - =A0 =A0 =A0 p->setattr =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D pnfs4_proc_se=
tattr;
> =A0 =A0 =A0 =A0p->read_done =A0 =A0 =A0 =A0 =A0 =A0=3D pnfs4_read_don=
e;
> =A0 =A0 =A0 =A0p->write_setup =A0 =A0 =A0 =A0 =A0=3D pnfs4_proc_write=
_setup;
> =A0 =A0 =A0 =A0p->write_done =A0 =A0 =A0 =A0 =A0 =3D pnfs4_write_done=
;
> --
> 1.6.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH] NFSv4.1: Use more sensible names for 'initialize_mountpoint'
Date: Thu, 21 Oct 2010 21:53:25 -0400
Message-ID: <AANLkTik7yqeA+1_xmWd4NqyTkrWv=BHAyWVYBs8_7H1U@mail.gmail.com>
References: <1287695683-17431-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46027 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab0JVBx1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 21:53:27 -0400
Received: by bwz11 with SMTP id 11so156707bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 18:53:25 -0700 (PDT)
In-Reply-To: <1287695683-17431-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me.

=46red


On Thu, Oct 21, 2010 at 5:14 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> The initialize_mountpoint/uninitialise_mountpoint functions are reall=
y about
> setting or clearing the layout driver to be used on this filesystem. =
Change
> the names to the more descriptive 'set_layoutdriver/clear_layoutdrive=
r'.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> =A0fs/nfs/nfs4filelayout.c | =A0 14 +++++++-------
> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
> =A0fs/nfs/pnfs.h =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
> =A03 files changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 9e82b51..2e92f0d 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -40,8 +40,8 @@ MODULE_LICENSE("GPL");
> =A0MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
> =A0MODULE_DESCRIPTION("The NFSv4 file layout driver");
>
> -int
> -filelayout_initialize_mountpoint(struct nfs_server *nfss)
> +static int
> +filelayout_set_layoutdriver(struct nfs_server *nfss)
> =A0{
> =A0 =A0 =A0 =A0int status =3D pnfs_alloc_init_deviceid_cache(nfss->nf=
s_client,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0nfs4_fl_free_deviceid_callback);
> @@ -55,9 +55,9 @@ filelayout_initialize_mountpoint(struct nfs_server =
*nfss)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -/* Uninitialize a mountpoint by destroying its device list */
> -int
> -filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
> +/* Clear out the layout by destroying its device list */
> +static int
> +filelayout_clear_layoutdriver(struct nfs_server *nfss)
> =A0{
> =A0 =A0 =A0 =A0dprintk("--> %s\n", __func__);
>
> @@ -256,8 +256,8 @@ static struct pnfs_layoutdriver_type filelayout_t=
ype =3D {
> =A0 =A0 =A0 =A0.id =3D LAYOUT_NFSV4_1_FILES,
> =A0 =A0 =A0 =A0.name =3D "LAYOUT_NFSV4_1_FILES",
> =A0 =A0 =A0 =A0.owner =3D THIS_MODULE,
> - =A0 =A0 =A0 .initialize_mountpoint =A0 =3D filelayout_initialize_mo=
untpoint,
> - =A0 =A0 =A0 .uninitialize_mountpoint =3D filelayout_uninitialize_mo=
untpoint,
> + =A0 =A0 =A0 .set_layoutdriver =3D filelayout_set_layoutdriver,
> + =A0 =A0 =A0 .clear_layoutdriver =3D filelayout_clear_layoutdriver,
> =A0 =A0 =A0 =A0.alloc_lseg =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D filelayout_=
alloc_lseg,
> =A0 =A0 =A0 =A0.free_lseg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D filelayout_=
free_lseg,
> =A0};
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d1ad7df..db77342 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -75,7 +75,7 @@ void
> =A0unset_pnfs_layoutdriver(struct nfs_server *nfss)
> =A0{
> =A0 =A0 =A0 =A0if (nfss->pnfs_curr_ld) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfss->pnfs_curr_ld->uninitialize_mountp=
oint(nfss);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfss->pnfs_curr_ld->clear_layoutdriver(=
nfss);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0module_put(nfss->pnfs_curr_ld->owner);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0nfss->pnfs_curr_ld =3D NULL;
> @@ -115,7 +115,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, =
u32 id)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_no_driver;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0server->pnfs_curr_ld =3D ld_type;
> - =A0 =A0 =A0 if (ld_type->initialize_mountpoint(server)) {
> + =A0 =A0 =A0 if (ld_type->set_layoutdriver(server)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%s: Error initializing m=
ount point for layout driver %u.\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, id);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index cbba28c..e12367d 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -53,8 +53,8 @@ struct pnfs_layoutdriver_type {
> =A0 =A0 =A0 =A0const u32 id;
> =A0 =A0 =A0 =A0const char *name;
> =A0 =A0 =A0 =A0struct module *owner;
> - =A0 =A0 =A0 int (*initialize_mountpoint) (struct nfs_server *);
> - =A0 =A0 =A0 int (*uninitialize_mountpoint) (struct nfs_server *);
> + =A0 =A0 =A0 int (*set_layoutdriver) (struct nfs_server *);
> + =A0 =A0 =A0 int (*clear_layoutdriver) (struct nfs_server *);
> =A0 =A0 =A0 =A0struct pnfs_layout_segment * (*alloc_lseg) (struct pnf=
s_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
> =A0 =A0 =A0 =A0void (*free_lseg) (struct pnfs_layout_segment *lseg);
> =A0};
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

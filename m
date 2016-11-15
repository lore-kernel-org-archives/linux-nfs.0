Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:54393 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751749AbcKOV2y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2016 16:28:54 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Mayhew Scott <smayhew@redhat.com>
CC: Trond Myklebust <trondmy@primarydata.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfs: only show mountproto in /proc/mounts if set
Date: Tue, 15 Nov 2016 21:28:46 +0000
Message-ID: <56E2C0D6-40A3-45E9-815C-A50A94A3A95C@primarydata.com>
References: <1479243592-38858-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1479243592-38858-1-git-send-email-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 15, 2016, at 15:59, Scott Mayhew <smayhew@redhat.com> wrote:
>=20
> The nfs_server->mountd_protocol field doesn't get set when a v3 submount
> is created, causing /proc/mounts to show 'mountproto=3D' without a netid.
> This in turn causes umount.nfs to emit the error message "Failed to find
> '' protocol" if you manually unmount the submount.
>=20
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
> fs/nfs/super.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 001796b..b60946d 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -532,7 +532,8 @@ static void nfs_show_mountd_netid(struct seq_file *m,=
 struct nfs_server *nfss,
> {
> =09struct sockaddr *sap =3D (struct sockaddr *) &nfss->mountd_address;
>=20
> -=09seq_printf(m, ",mountproto=3D");
> +=09if (nfss->mountd_protocol || showdefaults)
> +=09=09seq_printf(m, ",mountproto=3D");
> =09switch (sap->sa_family) {
> =09case AF_INET:
> =09=09switch (nfss->mountd_protocol) {

Does it make sense to call nfs_show_mountd_options() at all for the case of=
 a v3 submount?



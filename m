Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:44506 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751296AbcIPVUq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 17:20:46 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Fields Bruce James <bfields@fieldses.org>
Subject: Re: [PATCH v3 8/9] nfs: move nfs4 lock retry attempt loop to a
 separate function
Date: Fri, 16 Sep 2016 21:20:41 +0000
Message-ID: <B44BF606-A37E-430A-B076-AF8050F4CBAD@primarydata.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
 <1474057631-31209-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057631-31209-9-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 16, 2016, at 16:27, Jeff Layton <jlayton@redhat.com> wrote:
>=20
> This also consolidates the waiting logic into a single function,
> instead of having it spread across two like it is now.
>=20
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/nfs4proc.c | 51 ++++++++++++++++++++++++--------------------------=
-
> 1 file changed, 24 insertions(+), 27 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c807850ac476..a7517abaf3c7 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5530,22 +5530,6 @@ int nfs4_proc_delegreturn(struct inode *inode, str=
uct rpc_cred *cred, const nfs4
> =09return err;
> }
>=20
> -#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
> -#define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
> -
> -/*=20
> - * sleep, with exponential backoff, and retry the LOCK operation.=20
> - */
> -static unsigned long
> -nfs4_set_lock_task_retry(unsigned long timeout)
> -{
> -=09freezable_schedule_timeout_interruptible(timeout);
> -=09timeout <<=3D 1;
> -=09if (timeout > NFS4_LOCK_MAXTIMEOUT)
> -=09=09return NFS4_LOCK_MAXTIMEOUT;
> -=09return timeout;
> -}
> -
> static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct fil=
e_lock *request)
> {
> =09struct inode *inode =3D state->inode;
> @@ -6178,12 +6162,34 @@ static int nfs4_proc_setlk(struct nfs4_state *sta=
te, int cmd, struct file_lock *
> =09return err;
> }
>=20
> +#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
> +#define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
> +
> +static int
> +nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *re=
quest)
> +{
> +=09int status;
> +=09unsigned long timeout =3D NFS4_LOCK_MINTIMEOUT;
> +
> +=09do {
> +=09=09status =3D nfs4_proc_setlk(state, cmd, request);
> +=09=09if ((status !=3D -EAGAIN) || IS_SETLK(cmd))
> +=09=09=09break;
> +=09=09freezable_schedule_timeout_interruptible(timeout);
> +=09=09timeout *=3D 2;
> +=09=09timeout =3D min_t(unsigned long, NFS4_LOCK_MAXTIMEOUT, timeout);
> +=09=09status =3D -ERESTARTSYS;
> +=09=09if (signalled())
> +=09=09=09break;
> +=09} while(status < 0);

Can it ever be >=3D 0 here? Why not just use 'while (!signalled())'?

> +=09return status;
> +}
> +
> static int
> nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
> {
> =09struct nfs_open_context *ctx;
> =09struct nfs4_state *state;
> -=09unsigned long timeout =3D NFS4_LOCK_MINTIMEOUT;
> =09int status;
>=20
> =09/* verify open state */
> @@ -6232,16 +6238,7 @@ nfs4_proc_lock(struct file *filp, int cmd, struct =
file_lock *request)
> =09if (status !=3D 0)
> =09=09return status;
>=20
> -=09do {
> -=09=09status =3D nfs4_proc_setlk(state, cmd, request);
> -=09=09if ((status !=3D -EAGAIN) || IS_SETLK(cmd))
> -=09=09=09break;
> -=09=09timeout =3D nfs4_set_lock_task_retry(timeout);
> -=09=09status =3D -ERESTARTSYS;
> -=09=09if (signalled())
> -=09=09=09break;
> -=09} while(status < 0);
> -=09return status;
> +=09return nfs4_retry_setlk(state, cmd, request);
> }
>=20
> int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *=
state, const nfs4_stateid *stateid)
> --=20
> 2.7.4
>=20


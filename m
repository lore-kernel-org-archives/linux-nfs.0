Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:32859 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751563Ab2CHRwO convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 12:52:14 -0500
MIME-Version: 1.0
In-Reply-To: <1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
	<1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com>
	<1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com>
	<1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 8 Mar 2012 12:52:12 -0500
Message-ID: <CAN-5tyG-w+ie3sxTwNA6e9x=CojxyDaJScJuCbS+9VE=yTmJNA@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4: Return the delegation if the server returns NFS4ERR_OPENMODE
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

wouldn't it be better for you to proactively return a read delegation
then unnecessarily erroring?

i also don't understand how this error occurs. doing a setattr in this
case you must have used a non-special stateid. the server would only
return an err_openmode if you sent the setattr with a read delegation
stateid. i guess my question is what stateid would you use that from
client's perspective represent a write-type state id but yet a server
would flag as having wrong access type?

also i'm curious why would a server, instead of returning
err_openmode, would not first recall your read delegation?

On Wed, Mar 7, 2012 at 5:40 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> If a setattr() fails because of an NFS4ERR_OPENMODE error, it is
> probably due to us holding a read delegation. Ensure that the
> recovery routines return that delegation in this case.
>
> Reported-by: Miklos Szeredi <miklos@szeredi.hu>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4_fs.h  |    1 +
>  fs/nfs/nfs4proc.c |   13 ++++++++++++-
>  2 files changed, 13 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 5c9b20b..8ccaf24 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -193,6 +193,7 @@ struct nfs4_exception {
>        long timeout;
>        int retry;
>        struct nfs4_state *state;
> +       struct inode *inode;
>  };
>
>  struct nfs4_state_recovery_ops {
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3d26bab..bfcaa03 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -259,18 +259,28 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>  {
>        struct nfs_client *clp = server->nfs_client;
>        struct nfs4_state *state = exception->state;
> +       struct inode *inode = exception->inode;
>        int ret = errorcode;
>
>        exception->retry = 0;
>        switch(errorcode) {
>                case 0:
>                        return 0;
> +               case -NFS4ERR_OPENMODE:
> +                       if (nfs_have_delegation(inode, FMODE_READ)) {
> +                               nfs_inode_return_delegation(inode);
> +                               exception->retry = 1;
> +                               return 0;
> +                       }
> +                       if (state == NULL)
> +                               break;
> +                       nfs4_schedule_stateid_recovery(server, state);
> +                       goto wait_on_recovery;
>                case -NFS4ERR_DELEG_REVOKED:
>                case -NFS4ERR_ADMIN_REVOKED:
>                case -NFS4ERR_BAD_STATEID:
>                        if (state != NULL)
>                                nfs_remove_bad_delegation(state->inode);
> -               case -NFS4ERR_OPENMODE:
>                        if (state == NULL)
>                                break;
>                        nfs4_schedule_stateid_recovery(server, state);
> @@ -1908,6 +1918,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>        struct nfs_server *server = NFS_SERVER(inode);
>        struct nfs4_exception exception = {
>                .state = state,
> +               .inode = inode,
>        };
>        int err;
>        do {
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

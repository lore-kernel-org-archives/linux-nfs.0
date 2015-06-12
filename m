Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f44.google.com ([209.85.216.44]:35300 "EHLO
	mail-vn0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbFLVV3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 17:21:29 -0400
Received: by vnbf129 with SMTP id f129so8008324vnb.2
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 14:21:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434142410-86401-1-git-send-email-kolga@netapp.com>
References: <1434142410-86401-1-git-send-email-kolga@netapp.com>
Date: Fri, 12 Jun 2015 17:21:28 -0400
Message-ID: <CAHQdGtQVgDcT53C+_GsFjQ-qdWy1XOhRgx5HAk-WCC-8ik7i+g@mail.gmail.com>
Subject: Re: [PATCH 1/1] Recover from stateid-type error on SETATTR
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 12, 2015 at 4:53 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR when
> delegation stateid was used. When no open state exists, in case of application
> calling truncate() on the file, client has no state to recover and fails with
> EIO.
>
> Instead, upon such error, return the bad delegation and then resend the
> SETATTR with a zero stateid.
>
> Signed-off: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ad7cf7e..2a85af3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -360,8 +360,14 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>                 case -NFS4ERR_DELEG_REVOKED:
>                 case -NFS4ERR_ADMIN_REVOKED:
>                 case -NFS4ERR_BAD_STATEID:
> -                       if (state == NULL)
> +                       if (state == NULL) {
> +                               if (inode && nfs4_have_delegation(inode,
> +                                               FMODE_READ)) {
> +                                       nfs4_inode_return_delegation(inode);
> +                                       exception->retry = 1;
> +                               }
>                                 break;
> +                       }
>                         ret = nfs4_schedule_stateid_recovery(server, state);
>                         if (ret < 0)
>                                 break;

My remaining question here is: We don't seem to be communicating the
_REVOKED state of the delegation to nfs4_schedule_stateid_recovery(),
so won't we continue to loop if state != NULL?

IOW: is there any reason not to do the same thing here that we already
do for NFS4ERR_OPENMODE? At the time when we wrote commit
3114ea7a24d32, there was a difference between
nfs_inode_return_delegation() and nfs_remove_bad_delegation(), but now
the former handles both cases...

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44367 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865Ab2C1Mt3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 08:49:29 -0400
Received: by iagz16 with SMTP id z16so1448649iag.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 05:49:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Wed, 28 Mar 2012 21:49:28 +0900
Message-ID: <CAKYAXd868TcdJandJbV5EWkXPaNVNUmKj-0pdK88CP21ZGB9qw@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
From: Namjae Jeon <linkinjeon@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. Trond.

Is it better if exception.retry set to zero instead goto ?

Thanks.

2012/3/28 Trond Myklebust <Trond.Myklebust@netapp.com>:
> We can currently loop forever in nfs4_lookup_root() and in
> nfs41_proc_secinfo_no_name(), if the first iteration returns a
> NFS4ERR_DELAY or something else that causes exception.retry to get
> set.
>
> Reported-by: Dros Adamson <Weston.Adamson@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4proc.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 45df7d4..ee9ca19 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2290,11 +2290,12 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
>                switch (err) {
>                case 0:
>                case -NFS4ERR_WRONGSEC:
> -                       break;
> +                       goto out;
>                default:
>                        err = nfs4_handle_exception(server, err, &exception);
>                }
>        } while (exception.retry);
> +out:
>        return err;
>  }
>
> @@ -6229,11 +6230,12 @@ nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
>                case 0:
>                case -NFS4ERR_WRONGSEC:
>                case -NFS4ERR_NOTSUPP:
> -                       break;
> +                       goto out;
>                default:
>                        err = nfs4_handle_exception(server, err, &exception);
>                }
>        } while (exception.retry);
> +out:
>        return err;
>  }
>
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:48800 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758243Ab2J0ODz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 10:03:55 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Reduce stack use in encode_exchange_id()
Date: Sat, 27 Oct 2012 14:03:48 +0000
Message-ID: <51F73D8A-993E-4BB8-A3AD-30E0CE0EF0C6@netapp.com>
References: <1351307195-4197-1-git-send-email-rees@umich.edu>
In-Reply-To: <1351307195-4197-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Jim, I'll test this and report back.

-dros

On Oct 26, 2012, at 11:06 PM, "Jim Rees" <rees@umich.edu> wrote:

> For comment only. I have not tested this.
> 
> encode_exchange_id() uses more stack space than necessary, giving a compile
> time warning. Reduce the size of the static buffer for implementation name.
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
> fs/nfs/nfs4xdr.c |    7 +++++--
> 1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 8dba6bd..ccd1dde 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1700,12 +1700,15 @@ static void encode_bind_conn_to_session(struct xdr_stream *xdr,
>    *p = 0;    /* use_conn_in_rdma_mode = False */
> }
> 
> +#define IMPL_NAME_LIMIT (sizeof(utsname()->sysname) + sizeof(utsname()->release) + \
> +             sizeof(utsname()->version) + sizeof(utsname()->machine) + 8)
> +
> static void encode_exchange_id(struct xdr_stream *xdr,
>                   struct nfs41_exchange_id_args *args,
>                   struct compound_hdr *hdr)
> {
>    __be32 *p;
> -    char impl_name[NFS4_OPAQUE_LIMIT];
> +    char impl_name[IMPL_NAME_LIMIT];
>    int len = 0;
> 
>    encode_op_hdr(xdr, OP_EXCHANGE_ID, decode_exchange_id_maxsz, hdr);
> @@ -1720,7 +1723,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
>    if (send_implementation_id &&
>        sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN) > 1 &&
>        sizeof(CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN)
> -        <= NFS4_OPAQUE_LIMIT + 1)
> +        <= sizeof(impl_name) + 1)
>        len = snprintf(impl_name, sizeof(impl_name), "%s %s %s %s",
>                   utsname()->sysname, utsname()->release,
>                   utsname()->version, utsname()->machine);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

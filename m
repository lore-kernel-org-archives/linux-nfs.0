Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:44088 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbaGALVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 07:21:04 -0400
Received: by mail-wg0-f50.google.com with SMTP id m15so9573833wgh.9
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 04:21:02 -0700 (PDT)
Message-ID: <53B2999C.6090401@cloudius-systems.com>
Date: Tue, 01 Jul 2014 14:21:00 +0300
From: Avi Kivity <avi@cloudius-systems.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix nfs4d readlink truncated packet
References: <1403792592-1517-1-git-send-email-avi@cloudius-systems.com>
In-Reply-To: <1403792592-1517-1-git-send-email-avi@cloudius-systems.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/26/2014 05:23 PM, Avi Kivity wrote:
> XDR requires 4-byte alignment; nfs4d READLINK reply writes out the padding,
> but truncates the packet to the padding-less size.
>
> Fix by taking the padding into consideration when truncating the packet.
>

Ping.  I should have mentioned that without this, readlink() returns an 
I/O error on the client.

> Signed-off-by: Avi Kivity <avi@cloudius-systems.com>
> ---
>   fs/nfsd/nfs4xdr.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 83baf2b..cba93ea 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3267,7 +3267,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
>   
>   	wire_count = htonl(maxcount);
>   	write_bytes_to_xdr_buf(xdr->buf, length_offset, &wire_count, 4);
> -	xdr_truncate_encode(xdr, length_offset + 4 + maxcount);
> +	xdr_truncate_encode(xdr, length_offset + 4 + ALIGN(maxcount, 4));
>   	if (maxcount & 3)
>   		write_bytes_to_xdr_buf(xdr->buf, length_offset + 4 + maxcount,
>   						&zero, 4 - (maxcount&3));


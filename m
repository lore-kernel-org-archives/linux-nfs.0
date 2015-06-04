Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25333 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbFDRY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 13:24:28 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 2/4] nfs: update maxsz values for SETCLIENTID and EXCHANGE_ID
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1433436269-12292-3-git-send-email-jeff.layton@primarydata.com>
Date: Thu, 4 Jun 2015 13:26:57 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>
Message-Id: <9DD12001-B3F6-428B-B350-0586AFBE3E08@oracle.com>
References: <1433436269-12292-1-git-send-email-jeff.layton@primarydata.com> <1433436269-12292-3-git-send-email-jeff.layton@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

On Jun 4, 2015, at 12:44 PM, Jeff Layton <jlayton@poochiereds.net> wrote:

> The spec allows for up to NFS4_OPAQUE_LIMIT (1k). While we'll almost
> certainly never use that much, these ops are generally the only ones
> in the compound so we might as well allow for them to be that large.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
> fs/nfs/nfs4xdr.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 2826e117e3df..e105b9363f0a 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -139,7 +139,7 @@ static int nfs4_stat_to_errno(int);
> #define encode_setclientid_maxsz \
> 				(op_encode_hdr_maxsz + \
> 				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
> -				XDR_QUADLEN(NFS4_SETCLIENTID_NAMELEN) + \
> +				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \

Should you add another word here for the length of the opaque?

> 				1 /* sc_prog */ + \
> 				1 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
> 				1 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
> @@ -288,7 +288,7 @@ static int nfs4_stat_to_errno(int);
> #define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
> 				encode_verifier_maxsz + \
> 				1 /* co_ownerid.len */ + \
> -				XDR_QUADLEN(NFS4_EXCHANGE_ID_LEN) + \
> +				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
> 				1 /* flags */ + \
> 				1 /* spa_how */ + \
> 				/* max is SP4_MACH_CRED (for now) */ + \
> -- 
> 2.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




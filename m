Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54335 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbaBUSXs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Feb 2014 13:23:48 -0500
Received: by mail-ob0-f181.google.com with SMTP id wp4so2546773obc.26
        for <linux-nfs@vger.kernel.org>; Fri, 21 Feb 2014 10:23:48 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] NFSd: NFSv4.1 OPEN must use the session-derived client id
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1393006233-15366-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 21 Feb 2014 13:23:25 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8E58638D-ABFA-4056-BA94-640CEA42DA48@primarydata.com>
References: <1393006233-15366-1-git-send-email-trond.myklebust@primarydata.com>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 21, 2014, at 13:10, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> RFC5661 states:
> 
> The client can set the clientid field to any value and the server MUST
> ignore it.  Instead, the server MUST derive the client ID from the
> session ID of the SEQUENCE operation of the COMPOUND request
> 
> Make it so...
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfsd/nfs4state.c | 17 +++++++++++++++++
> 1 file changed, 17 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 693e1458e2ca..d23f4cdbc891 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2826,6 +2826,21 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
> 	return nfserr_bad_seqid;
> }
> 
> +/*
> + * RFC5661: OPEN MUST ignore the client-supplied clientid argument and
> + * substitute the session clientid
> + */
> +static void nfsd41_set_open_clientid(struct nfsd4_compound_state *cstate,
> +		struct nfsd4_open *open)
> +{
> +	struct nfs4_client *clp;
> +
> +	if (!nfsd4_has_session(cstate))
> +		return;
> +	clp = cstate->session->se_client;
> +	memcpy(&open->op_clientid, &clp->cl_clientid, sizeof(open->op_clientid));
> +}
> +
> __be32
> nfsd4_process_open1(struct nfsd4_compound_state *cstate,
> 		    struct nfsd4_open *open, struct nfsd_net *nn)
> @@ -2836,6 +2851,8 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
> 	struct nfs4_openowner *oo = NULL;
> 	__be32 status;
> 
> +	nfsd41_set_open_clientid(cstate, open);
> +
> 	if (STALE_CLIENTID(&open->op_clientid, nn))
> 		return nfserr_stale_clientid;

Never mind. There seems to be code to do this in nfsd4_open()...

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60108 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752801Ab1FMVKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 17:10:00 -0400
Date: Mon, 13 Jun 2011 17:09:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sid Moore <learnmost@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [Patch 1/1]: fixed a bug that EXCHGID4_FLAG_CONFIRMED_R is
 cleared in EXCHANGE_ID reply if incarnation is a confirmed client
Message-ID: <20110613210959.GB22174@fieldses.org>
References: <BANLkTinHJm4be+gRrCeYdJg_B3ptt+A0qw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <BANLkTinHJm4be+gRrCeYdJg_B3ptt+A0qw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 13, 2011 at 09:27:19AM +0800, Sid Moore wrote:
> On Sun, Jun 12, 2011 at 7:59 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Sat, Jun 11, 2011 at 03:54:56PM +0800, Sid Moore wrote:
> >> Hi
> >>
> >> on Linux NFSv4.1 server, nfsd4_exchange_id() is used for creating a
> >> new client incarnation or updating a confirmed client incarnation. if
> >> try to update a confirmed incarnation, EXCHGID4_FLAG_CONFIRMED_R
> >> should be set in eir_flags according to section 18.35.3, RFC5661.
> >>
> >> but I found EXCHGID4_FLAG_CONFIRMED_R is cleared by "clid->flags =
> >> new->cl_exchange_flags;", which is in nfsd4_set_ex_flags() called by
> >> nfsd4_exchange_id().
> >>
> >> so the sematics of RFC5661 is broken? am I correct?
> >
> > On a quick glance.... I think you're correct.  Patch welcomed.
> >
> > --b.
> >
> 
> Hi, Bruce
> 
> I think the patch below might be able to fix this issue. I am not sure
> what impact would be produced if EXCHGID4_FLAG_CONFIRMED_R directly
> set on confirmed clients. So, I take a conservative way. Please review
> it. Thanks.

Grepping for cl_exchange_flags on the server side....  I think it would
be fine just to set it directly.  Would you mind trying that and
resending the patch if it works?

--b.

> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6fb7283..4bd9281 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1394,6 +1394,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  	char			addr_str[INET6_ADDRSTRLEN];
>  	nfs4_verifier		verf = exid->verifier;
>  	struct sockaddr		*sa = svc_addr(rqstp);
> +	int 			confirmed_clnt = 0;
> 
>  	rpc_ntop(sa, addr_str, sizeof(addr_str));
>  	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
> @@ -1455,7 +1456,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		 * Set bit when the owner id and verifier map to an already
>  		 * confirmed client id (18.35.3).
>  		 */
> -		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
> +		confirmed_clnt = 1;
> 
>  		/*
>  		 * Falling into 18.35.4 case 2, possible router replay.
> @@ -1498,6 +1499,9 @@ out_copy:
> 
>  	exid->seqid = 1;
>  	nfsd4_set_ex_flags(new, exid);
> +	if (confirmed_clnt)
> +		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
> +
> 
>  	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
>  		new->cl_cs_slot.sl_seqid, new->cl_exchange_flags);
> 
> --
> Sid

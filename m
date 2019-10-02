Return-Path: <SRS0=5NlU=X3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CB1FC4360C
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Oct 2019 19:55:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1A9D02133F
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Oct 2019 19:55:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728124AbfJBTzM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Oct 2019 15:55:12 -0400
Received: from fieldses.org ([173.255.197.46]:40798 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725951AbfJBTzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Oct 2019 15:55:12 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id E18841C84; Wed,  2 Oct 2019 15:55:11 -0400 (EDT)
Date:   Wed, 2 Oct 2019 15:55:11 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v7 18/19] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20191002195511.GA21809@fieldses.org>
References: <20190916211353.18802-1-olga.kornievskaia@gmail.com>
 <20190916211353.18802-19-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190916211353.18802-19-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Sep 16, 2019 at 05:13:52PM -0400, Olga Kornievskaia wrote:
> @@ -1956,6 +1964,45 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  		- rqstp->rq_auth_slack;
>  }
>  
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +static __be32
> +check_if_stalefh_allowed(struct nfsd4_compoundargs *args)
> +{
> +	struct nfsd4_op	*op, *current_op, *saved_op;

current_op and saved_op need to be initialized to NULL here.

> +	struct nfsd4_copy *copy;
> +	struct nfsd4_putfh *putfh;
> +	int i;
> +
> +	/* traverse all operation and if it's a COPY compound, mark the
> +	 * source filehandle to skip verification
> +	 */
> +	for (i = 0; i < args->opcnt; i++) {
> +		op = &args->ops[i];
> +		if (op->opnum == OP_PUTFH)
> +			current_op = op;
> +		else if (op->opnum == OP_SAVEFH)
> +			saved_op = current_op;
> +		else if (op->opnum == OP_RESTOREFH)
> +			current_op = saved_op;
> +		else if (op->opnum == OP_COPY) {
> +			copy = (struct nfsd4_copy *)&op->u;
> +			if (!saved_op)
> +				return nfserr_nofilehandle;

Looks like this results in returning an empty compound result with just
the bare result.  I believe what we need to do is execute all the
ops preceding the COPY normally, then return the nofilehandle error on
the COPY.

One approach might be

		if (!saved_op) {
			op->status = nfserr_nofilehandle;
			return;
		}

and change check_if_stalefh_allowed to have no return value.

--b.

> +			putfh = (struct nfsd4_putfh *)&saved_op->u;
> +			if (!copy->cp_intra)
> +				putfh->no_verify = true;
> +		}
> +	}
> +	return nfs_ok;
> +}
...
> @@ -2004,6 +2051,9 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  		resp->opcnt = 1;
>  		goto encode_op;
>  	}
> +	status = check_if_stalefh_allowed(args);
> +	if (status)
> +		goto out;

>  
>  	trace_nfsd_compound(rqstp, args->opcnt);
>  	while (!status && resp->opcnt < args->opcnt) {

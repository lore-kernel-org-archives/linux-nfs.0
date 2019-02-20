Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07D6EC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:12:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C09F821738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:12:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726235AbfBTCMI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 21:12:08 -0500
Received: from fieldses.org ([173.255.197.46]:47902 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725616AbfBTCMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 21:12:08 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 578DE1C22; Tue, 19 Feb 2019 21:12:08 -0500 (EST)
Date:   Tue, 19 Feb 2019 21:12:08 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 06/10] NFSD add COPY_NOTIFY operation
Message-ID: <20190220021208.GG19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-7-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-7-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:44PM -0500, Olga Kornievskaia wrote:
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 0152b34..51fca9e 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
...
> @@ -1348,6 +1350,43 @@ struct nfsd4_copy *
>  }
>  
>  static __be32
> +nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		  union nfsd4_op_u *u)
> +{
> +	struct nfsd4_copy_notify *cn = &u->copy_notify;
> +	__be32 status;
> +	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> +	struct nfs4_stid *stid;
> +	struct nfs4_cpntf_state *cps;
> +
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> +					&cn->cpn_src_stateid, RD_STATE, NULL,
> +					NULL, &stid);
> +	if (status)
> +		return status;
> +
> +	cn->cpn_sec = nn->nfsd4_lease;
> +	cn->cpn_nsec = 0;

I'm pretty sure this should be cp_timeout, not 0.

--b.

Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3491CECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 17:12:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 012D12077B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 17:12:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 012D12077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726634AbeKICs3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 21:48:29 -0500
Received: from fieldses.org ([173.255.197.46]:38676 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726585AbeKICs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 21:48:29 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C2E138BF; Thu,  8 Nov 2018 12:12:02 -0500 (EST)
Date:   Thu, 8 Nov 2018 12:12:02 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: COPY and CLONE operations require the saved
 filehandle to be set
Message-ID: <20181108171202.GC4947@fieldses.org>
References: <20181108161136.18376-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108161136.18376-1-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applying for 4.20 and stable, thanks!

--b.

On Thu, Nov 08, 2018 at 11:11:36AM -0500, Scott Mayhew wrote:
> Make sure we have a saved filehandle, otherwise we'll oops with a null
> pointer dereference in nfs4_preprocess_stateid_op().
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index edff074d38c7..d505990dac7c 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1038,6 +1038,9 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  {
>  	__be32 status;
>  
> +	if (!cstate->save_fh.fh_dentry)
> +		return nfserr_nofilehandle;
> +
>  	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
>  					    src_stateid, RD_STATE, src, NULL);
>  	if (status) {
> -- 
> 2.17.1

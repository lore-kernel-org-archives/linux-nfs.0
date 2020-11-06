Return-Path: <SRS0=hdvH=EM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 991E8C2D0A3
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:28:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2BA1520704
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:28:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="iWXxdUAk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728852AbgKFW2D (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Nov 2020 17:28:03 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34710 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728390AbgKFW2D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2020 17:28:03 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 30BAFC0613CF
        for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2020 14:28:03 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id BBA476191; Fri,  6 Nov 2020 17:28:02 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org BBA476191
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1604701682;
        bh=d2QQ2HBZsHOAinPj1O1VSlKBE/2tLlMmWbv3CEoDi+Y=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=iWXxdUAk64TeMFts2+BY7uuDS5c0zacdhCFNV1f+FO38PEaQkZa+6WoEBFuIlhnjB
         pu/HLaBiQhDVborzACT6NHaw1BPEaPNLHAw/x35EqHHAoAFSR+NnYMXP/MPyfagmG3
         PPbqYr8UrfKkOxLd7hZWmSKDujih3ZILgSV7sWYw=
Date:   Fri, 6 Nov 2020 17:28:02 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix general protection fault in
 trace_rpc_xdr_overflow()
Message-ID: <20201106222802.GG26028@fieldses.org>
References: <160346406748.79082.3077185849414818247.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <160346406748.79082.3077185849414818247.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Also applied.--b.

On Fri, Oct 23, 2020 at 10:41:07AM -0400, Chuck Lever wrote:
> The TP_fast_assign() section is careful enough not to dereference
> xdr->rqst if it's NULL. The TP_STRUCT__entry section is not.
> 
> Fixes: 5582863f450c ("SUNRPC: Add XDR overflow trace event")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/trace/events/sunrpc.h |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> index f45b3c01370c..2477014e3fa6 100644
> --- a/include/trace/events/sunrpc.h
> +++ b/include/trace/events/sunrpc.h
> @@ -655,10 +655,10 @@ TRACE_EVENT(rpc_xdr_overflow,
>  		__field(size_t, tail_len)
>  		__field(unsigned int, page_len)
>  		__field(unsigned int, len)
> -		__string(progname,
> -			 xdr->rqst->rq_task->tk_client->cl_program->name)
> -		__string(procedure,
> -			 xdr->rqst->rq_task->tk_msg.rpc_proc->p_name)
> +		__string(progname, xdr->rqst ?
> +			 xdr->rqst->rq_task->tk_client->cl_program->name : "unknown")
> +		__string(procedure, xdr->rqst ?
> +			 xdr->rqst->rq_task->tk_msg.rpc_proc->p_name : "unknown")
>  	),
>  
>  	TP_fast_assign(
> 

Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D414C07E96
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Jul 2021 23:31:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0847B61445
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Jul 2021 23:31:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229497AbhGHXdw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Jul 2021 19:33:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56906 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229491AbhGHXdw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2021 19:33:52 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 37860C061574
        for <linux-nfs@vger.kernel.org>; Thu,  8 Jul 2021 16:31:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=jra6eVCUb4QOC04fq6nucXKQ0jZAs8nzjUB1r1PZFhA=; b=QswHst436Z1sDOR32UFIIiumRx
        7DhL+HW0K11GdlWrHerWGHPwqRGIGLrynZGbN7nmDLcUcDhueKvxitmI1u1NLdkgh4O+ItnFpJ2zZ
        q8sOq7r4chvz+TCb1+cvgCB732YbCMYHeMYzoRBcWk5VM+X5UGT6cJNBcvDsYwz3B1/U26tJEGvbe
        WIcZcfBjlqg8bKs2XR5JisH73eyFIQCB+VEonxLI9crtz9kevDHUcLR7xFNKieW3n3V/ccKwMQ2x1
        sO97ejdSXZ+//XFeXEUdjb51317N1WrscvFUlZgKY3xIa5lvUkYEedcXwZejOtACbhFR+puMtGAso
        Ge6yaP1g==;
Received: from willy by casper.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1m1dTu-00Dw5R-Kl; Thu, 08 Jul 2021 23:31:00 +0000
Date:   Fri, 9 Jul 2021 00:30:58 +0100
From:   Matthew Wilcox <willy@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-mm@kvack.org, neilb@suse.de
Subject: Re: [PATCH v3 2/3] SUNRPC: Add svc_rqst_replace_page() API
Message-ID: <YOeKsmTT5L9qjvXN@casper.infradead.org>
References: <162575623717.2532.8517369487503961860.stgit@klimt.1015granger.net>
 <162575798916.2532.6898942885852856593.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162575798916.2532.6898942885852856593.stgit@klimt.1015granger.net>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jul 08, 2021 at 11:26:29AM -0400, Chuck Lever wrote:
> @@ -256,6 +256,9 @@ struct svc_rqst {
>  	struct page *		*rq_next_page; /* next reply page to use */
>  	struct page *		*rq_page_end;  /* one past the last page */
>  
> +	struct page		*rq_relpages[16];
> +	int			rq_numrelpages;

This is only one struct page away from being a pagevec ... ?

> @@ -838,6 +839,33 @@ svc_set_num_threads_sync(struct svc_serv *serv, struct svc_pool *pool, int nrser
>  }
>  EXPORT_SYMBOL_GPL(svc_set_num_threads_sync);
>  
> +static void svc_rqst_release_replaced_pages(struct svc_rqst *rqstp)
> +{
> +	release_pages(rqstp->rq_relpages, rqstp->rq_numrelpages);
> +	rqstp->rq_numrelpages = 0;

This would be pagevec_release()


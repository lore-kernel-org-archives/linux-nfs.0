Return-Path: <SRS0=3r48=B6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2D03C433E3
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 23:37:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7E668207DF
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 23:37:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aXXL28HG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728886AbgHTXhw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Aug 2020 19:37:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47126 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728498AbgHTXhv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2020 19:37:51 -0400
Received: from mail-wm1-x342.google.com (mail-wm1-x342.google.com [IPv6:2a00:1450:4864:20::342])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1CFABC061385;
        Thu, 20 Aug 2020 16:37:50 -0700 (PDT)
Received: by mail-wm1-x342.google.com with SMTP id k8so71536wma.2;
        Thu, 20 Aug 2020 16:37:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=a11ZuS2tn9ABUSZlK+DDzav04GPXb6ukte2Rq00o4oM=;
        b=aXXL28HGiNhggEu5C8ufTABck2Yla4BKi3kyLYKH79FT3XehjvoX3htc74rN+qZGZC
         u/JCZyQ2hup4fLR34RUgGuCBT0ZKGYeWIfdQgJH+G3vElEcPmU+zPVbj5DE+Ee4VsGEF
         y39oShumgC2+RPqR2ZL7TvHlNWzPc5Vcqlta4gdef0lmNYhMifoam4NVO/XnfLzXyUEX
         r5/dX5Stn4GVyagV3sb0smDqHwlUMTvVvFM8zya8ioQZZMBK4+/tVAdGYoZ34sLVN9se
         HVGpeYs+YEV1y6qsRXIyFFnAJsfpIkWIZdjN9ZEoCpHF1KislY6d/67kENgUXeZix5cC
         FeLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:date:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=a11ZuS2tn9ABUSZlK+DDzav04GPXb6ukte2Rq00o4oM=;
        b=aTr5k+824j+CY4tyWh1vqJO6PcYZKZuseMH8xXUsNMnvQotZEynJJ1nb3ffFl+78Nf
         NxF7c9xDQgFDD0NlkgFsDpvAo6Ktt0oHgTz4FON7PUjvx2SZS4I2WAZ13SQ6qB31ygZi
         xJWn6ajrUgZJUtcbxA2JDJgwjA+vUYQ1bvC2gO6uhpRFZBk/5H4cAvZBy3dm23g9iKDg
         sqyWx5JP/CNmYbdjgj++B2+hEFc8ESJPsuFl32Z92Jn6PQ5rND1Oj0uu8ua1vgVm2yaN
         NzwaYMuqUlfBvNUHrK+ZvCSjuD2cQBvmU9RbbQ4EwJhYXHnPIHnxuwmfX5nkWVn/B6hV
         kDGw==
X-Gm-Message-State: AOAM531BAu0p1gx2ujWiRYdD4EfTY+REcVcCIDoaTtUQtZKsC/f/bQnV
        sNvYcwSC9qqRMmdkibE5fFWkQvVQW9XCM++a
X-Google-Smtp-Source: ABdhPJzkkPY8Ww57p4qVpPsWYPaamfwP6TDoUkYbhwKeQvhhkf8Sf0PxXXYvPU5yblJ7U1t3AmW+Bw==
X-Received: by 2002:a05:600c:2209:: with SMTP id z9mr161912wml.70.1597966668854;
        Thu, 20 Aug 2020 16:37:48 -0700 (PDT)
Received: from medion (cpc83661-brig20-2-0-cust443.3-3.cable.virginm.net. [82.28.105.188])
        by smtp.gmail.com with ESMTPSA id 202sm518802wmb.10.2020.08.20.16.37.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 20 Aug 2020 16:37:48 -0700 (PDT)
From:   Alex Dewar <alex.dewar90@gmail.com>
X-Google-Original-From: Alex Dewar <alex.dewar@gmx.co.uk>
Date:   Fri, 21 Aug 2020 00:37:45 +0100
To:     Frank van der Linden <fllinden@amazon.com>
Cc:     Alex Dewar <alex.dewar90@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: Remove unnecessary assignment in nfs4xdr.c
Message-ID: <20200820233745.fhfsbx63td3u5guy@medion>
References: <20200812141252.21059-1-alex.dewar90@gmail.com>
 <20200812203631.GA13358@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200812203631.GA13358@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Aug 12, 2020 at 08:36:31PM +0000, Frank van der Linden wrote:
> On Wed, Aug 12, 2020 at 03:12:51PM +0100, Alex Dewar wrote:
> > 
> > In nfsd4_encode_listxattrs(), the variable p is assigned to at one point
> > but this value is never used before p is reassigned. Fix this.
> > 
> > Addresses-Coverity: ("Unused value")
> > Signed-off-by: Alex Dewar <alex.dewar90@gmail.com>
> > ---
> >  fs/nfsd/nfs4xdr.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 259d5ad0e3f47..1a0341fd80f9a 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -4859,7 +4859,7 @@ nfsd4_encode_listxattrs(struct nfsd4_compoundres *resp, __be32 nfserr,
> >                         goto out;
> >                 }
> > 
> > -               p = xdr_encode_opaque(p, sp, slen);
> > +               xdr_encode_opaque(p, sp, slen);
> > 
> >                 xdrleft -= xdrlen;
> >                 count++;
> > --
> > 2.28.0
> > 
> 
> Yep, I guess my linting missed that, thanks for the fix.
> 
> - Frank

Ping? The second patch in this series had a mistake in it, but I think
this one's still good to go :-)

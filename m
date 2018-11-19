Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F82C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 22:41:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 56A1F20851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 22:41:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lHIT8NL6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56A1F20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731506AbeKTJHj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 04:07:39 -0500
Received: from mail-pg1-f195.google.com ([209.85.215.195]:34266 "EHLO
        mail-pg1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731047AbeKTJHi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 04:07:38 -0500
Received: by mail-pg1-f195.google.com with SMTP id 17so14201383pgg.1
        for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2018 14:41:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vCPAVryRevop6HtMhWH2k7boznBVlvNBhS5PTGSUvZQ=;
        b=lHIT8NL6exAIl9ltVLQ/g7RvVHvOfJTNjFB6VF7k88F88XyfUKtJp4ZQFnvSpBBeri
         fxnSEmdyiJpMvkPNyxQW/f8y50kXyj+M9Lhn1qqPL1JfZTRRcvrZym/xOTnSquEH3GSr
         4hX8Yjgl3VYYt+pjrJgtPNH414mYaRZ90+bRBIKYNAblshAcdIfhetOZBdK8fWNCMEZf
         SHIRtIR2hiqoPH2FnP13Kui5AGe/kEr652P/NMPguwsI2pLsb2cV7tYIGglfgcZ+Ivhk
         nkYl67OiYtSUoai7r7HuBdh9ydQLgnV4NX3A3wrSW8JnoM/uPpTW6aVn3ZHD7I5VtSI6
         zkqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=vCPAVryRevop6HtMhWH2k7boznBVlvNBhS5PTGSUvZQ=;
        b=UltPWdGoN+w9i4sBdM8LMycaLNzE45n3l74wjS5sZ0q5Evbdeh/SwjlF5haxugkDLJ
         lkRPVB89SDTT2fPJvdAUBapjHYCMH8p+YL0LEZlr5UjOVavDu1iYKh+YIHpCnsLfsi0f
         EbG5ZjErTxIxY7D/EtFWVoo0wW78nsTUwG+PnFDP7jm48pedEz3/VDCKTl4CDn3cT8zl
         s6TNwtxeju1Xx3FvaXDzRJEOXephgYtagg45cyvHVvwRoE/3iIEA97Jd2KJD/4qRl2Lf
         J/QNKcfagHYQQXiZW5cN3VLCSRyVJbS7Ov+h/llmGWjBJQFr3WBrUdtNA5yVQ7OlFts0
         kiVg==
X-Gm-Message-State: AGRZ1gKzNXWXACYvaykUTzpU5j1S5rDAWVLrRC9XbhLqQ2H44+CImimN
        aA3wpsTfWdKrp3OwbCdt0NG4FQ==
X-Google-Smtp-Source: AJdET5fLpNmZBYStrBB03Lw8PBMfa1Qw1erbSNU0gDweqMF7YNOZTvPfphHpmpuQLy5+xLBnN7YJHw==
X-Received: by 2002:a63:7b06:: with SMTP id w6mr21785315pgc.288.1542667305954;
        Mon, 19 Nov 2018 14:41:45 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id s2sm7133652pfa.167.2018.11.19.14.41.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 14:41:45 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
        (envelope-from <jgg@ziepe.ca>)
        id 1gOsEh-0008El-UD; Mon, 19 Nov 2018 15:41:43 -0700
Date:   Mon, 19 Nov 2018 15:41:43 -0700
From:   Jason Gunthorpe <jgg@ziepe.ca>
To:     Bart Van Assche <bvanassche@acm.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, oulijun@huawei.com, umalhi@cisco.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
Message-ID: <20181119224143.GL4890@ziepe.ca>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154551.10832.5498.stgit@manet.1015granger.net>
 <1542644197.185366.50.camel@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542644197.185366.50.camel@acm.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 08:16:37AM -0800, Bart Van Assche wrote:
> On Mon, 2018-11-19 at 10:45 -0500, Chuck Lever wrote:
> > FMR is not supported on most recent RDMA devices. It is also slower
> > and less secure than FRWR. As discussed during the RDMA BoF at LPC
> > 2018, it is time to remove support for FMR in the NFS/RDMA client
> > stack. NFS/RDMA server-side uses either local memory registration or
> > FRWR.  There is no change required there to deprecate FMR.
> > 
> > There are a few Infiniband/RoCE devices in the kernel tree that do
> > not support MEM_MGT_EXTENSIONS, and therefore will no longer support
> > client-side NFS/RDMA. These are:
> > 
> >  - mthca
> >  - qib

Ooh, qib was not in the list when we talked on this in plumbers. That
does change things. 

Dennis: Could qib be changed? HFI1 supports FRWR right?

> >  - usnic
> >  - hns (RoCE)
> 
> Can someone from Intel comment on how many of their customers rely on the qib
> driver?
> 
> Can someone from Cisco comment on how many of their customers rely on the usnic
> driver?

Ignore usnic, it is not a RDMA driver

> Can someone from Huawei comment on how many of their customers rely on the hns
> driver?

Nor was this, this is an actively used driver..

Could hns do FRWR? It is very disappointing that such a new driver
does not support FRWR.

I guess it is worth stating again that FMR is deprecated. People are
going to be disappointed if they try to submit new drivers that don't
support FRWR :(

Jason

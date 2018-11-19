Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB626C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 23:10:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E18A20823
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 23:10:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cFfiZXiM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E18A20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730860AbeKTJge (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 04:36:34 -0500
Received: from mail-pf1-f193.google.com ([209.85.210.193]:35550 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731164AbeKTJgd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 04:36:33 -0500
Received: by mail-pf1-f193.google.com with SMTP id z9so9965pfi.2
        for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2018 15:10:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qVvtqUTsp0KbVAPB2U1CDBnbxFKBjSYS3Au6QIoBrK0=;
        b=cFfiZXiMZ0P2DcoXWuR7CwrBY9drG6tf82yxa+wHpHBLYOnM22qeCMpuiHi+7/k2/6
         nIpm3n1qUj1cRNnZLLMYDDnwFlKSS0GyGYwFN3nRqMJNwiwmTVoNzj6esRE8QW3B9DJd
         VDtuikq/U36ZNUus3U+ZSUrljFdlKjaquDQgRNWVrXW7cTf8X+O5uQoJFIdSQL21dvsD
         q5okEK9ZMHBAGvOkE4CUprzPrxmyZ6EZS8WszTsKRmvx2gLhqneZAvAEqpQzk5+bBEIH
         0Z+2IQ6fnVOC/Flj2SDmiQPkTgG2tTWJkXvBae1gDUAmrd5+zV+ullLnzaqcfpNdoaRB
         JT3Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=qVvtqUTsp0KbVAPB2U1CDBnbxFKBjSYS3Au6QIoBrK0=;
        b=Kze55oS3D7Xpmcfy2vmD+ww9udXvcbSAPBfuu+TG61e/Z7jHpTm6Pw9SpgQP/3r01M
         mvd37iDnhcQ8ce72kT44KfoX1Evn3VIPjaVWlsdX3kZcizsoOZ//GTzqqw1gZXNcWVyJ
         t4ujPobp6nAAuCdmuXtquGQ3PpxU6kZKmhxrRH3JtrAA9RII+a5dCcVczSGgLhbEIPxl
         XenoOA+i6DIV6zhaOIcOK3aFVP49guDaYFutGhG+6BhRbwKpv7OAVBlxscfJLqEDW8Fu
         4TMWwgQfeXKuogI3KyHp5vyQkgykmx2AbGQQ5nz1gtN2AkjZvDeyq7XFK2kRmNt+ytef
         QsDw==
X-Gm-Message-State: AGRZ1gIxfOnB2CTmx70xJAjZpI6C6+rt3IJElVXesp3FOk0BgBpyeRgC
        dXH00vq01mpQQsQGwmVCEhaDow==
X-Google-Smtp-Source: AJdET5eYm9GG/5gHPvl6g/05iSwKXgBDIkhzdWIRBj17xDhhvRDSEKemONSdyHIr+7X5Z76w10d8JQ==
X-Received: by 2002:a63:741:: with SMTP id 62mr21244800pgh.352.1542669033948;
        Mon, 19 Nov 2018 15:10:33 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id x184-v6sm33699917pfx.42.2018.11.19.15.10.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 15:10:33 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
        (envelope-from <jgg@ziepe.ca>)
        id 1gOsga-0008Pj-EC; Mon, 19 Nov 2018 16:10:32 -0700
Date:   Mon, 19 Nov 2018 16:10:32 -0700
From:   Jason Gunthorpe <jgg@ziepe.ca>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Bart Van Assche <bvanassche@acm.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Lijun Ou <oulijun@huawei.com>, umalhi@cisco.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
Message-ID: <20181119231032.GO4890@ziepe.ca>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154551.10832.5498.stgit@manet.1015granger.net>
 <1542644197.185366.50.camel@acm.org>
 <20181119224143.GL4890@ziepe.ca>
 <1172062C-E8CB-4F37-905D-F40EC8D9270C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1172062C-E8CB-4F37-905D-F40EC8D9270C@oracle.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 05:56:54PM -0500, Chuck Lever wrote:
> 
> 
> > On Nov 19, 2018, at 5:41 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > 
> > On Mon, Nov 19, 2018 at 08:16:37AM -0800, Bart Van Assche wrote:
> >> On Mon, 2018-11-19 at 10:45 -0500, Chuck Lever wrote:
> >>> FMR is not supported on most recent RDMA devices. It is also slower
> >>> and less secure than FRWR. As discussed during the RDMA BoF at LPC
> >>> 2018, it is time to remove support for FMR in the NFS/RDMA client
> >>> stack. NFS/RDMA server-side uses either local memory registration or
> >>> FRWR.  There is no change required there to deprecate FMR.
> >>> 
> >>> There are a few Infiniband/RoCE devices in the kernel tree that do
> >>> not support MEM_MGT_EXTENSIONS, and therefore will no longer support
> >>> client-side NFS/RDMA. These are:
> >>> 
> >>> - mthca
> >>> - qib
> > 
> > Ooh, qib was not in the list when we talked on this in plumbers. That
> > does change things. 
> > 
> > Dennis: Could qib be changed? HFI1 supports FRWR right?
> > 
> >>> - usnic
> >>> - hns (RoCE)
> >> 
> >> Can someone from Intel comment on how many of their customers rely on the qib
> >> driver?
> >> 
> >> Can someone from Cisco comment on how many of their customers rely on the usnic
> >> driver?
> > 
> > Ignore usnic, it is not a RDMA driver
> > 
> >> Can someone from Huawei comment on how many of their customers rely on the hns
> >> driver?
> > 
> > Nor was this, this is an actively used driver..
> > 
> > Could hns do FRWR? It is very disappointing that such a new driver
> > does not support FRWR.
> > 
> > I guess it is worth stating again that FMR is deprecated. People are
> > going to be disappointed if they try to submit new drivers that don't
> > support FRWR :(
> 
> My methodology was to search for whether each driver asserts
> IB_DEVICE_MEM_MGT_EXTENSIONS in device_cap_flags.

Drivers might be broken here, or we might need more flags.

Searching for FWMR shows hits in hns, which is encouraging...

Jason

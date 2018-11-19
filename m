Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE035C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 22:46:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9373220851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 22:46:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nVqoEHC5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9373220851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731586AbeKTJMK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 04:12:10 -0500
Received: from mail-pg1-f196.google.com ([209.85.215.196]:37298 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731583AbeKTJMK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 04:12:10 -0500
Received: by mail-pg1-f196.google.com with SMTP id 80so14468039pge.4
        for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2018 14:46:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PPSXu8H2xgcUdxYgwdNyboKPVDBLPJ30THlmnHeC72k=;
        b=nVqoEHC5bn2GNXJAAZKwIe9xLndmMpL/KxnaZZDHm/Orj65SLD2ejzmAU7Tvg8RpV9
         RZwKrMC/4Zvn035DlXmoHoG0oTWhnUS+2XC9waUbx8Ys8wd4aFZmczQQdYWp7L+Wz7v5
         jPdk5Dv3700DEa9P/sjIpBHoyNfprYl7hxi3xcaoKqvcT+vl1aJt5Bg0AsQRxKRYbVUT
         W6cpPSXho001OU9hiDagtLSa1gxLg+75J2EoNcyU3pdrAZ/psTYz+bQEB4gaAXU5wszP
         1aq4Bm/L4AO1OgaB1dnJBH+LpvD7LtW8N0hW9ao6/301xt+5x2jX8fhW9YvnIllj5vve
         D6AA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=PPSXu8H2xgcUdxYgwdNyboKPVDBLPJ30THlmnHeC72k=;
        b=iJKhQqmUtP+opH3RqzQ/X13buBNvE4YTm5fLcUvnUStGlHCkfptC5oQiTSRqbn6IRL
         L4BNNS98wIlMuazQ11jIFR2t8oqwafGwfEKzrK8NYDamG/CBgWI/VmBQSl/rKm2m1rJf
         0aITzXVnGn4QxO0tX4XKmdBQPkM887/saw0vGAdtFf4VNskkN1sVZ936MFKwDVmNP0Yl
         wQlRGND/p+cSGzVeVwlWQ1T199UKOTiSr1SBrx4veDDW/OLNcLU6YoBvw5UnuD3XW/8M
         oSLHaBOu9ZoBmU9wGhOIQhkfeU3aKF5Cqzlzrz3kzJRo2FwlLpl/an4VxdMe7a0kt5OO
         4a9A==
X-Gm-Message-State: AGRZ1gJS2rSBQ/HRAF5paSeXoD6FviEDohboRXEtR7qcL73vt295hWIW
        b0rxLIV8YCy/0rxB/059YjLqyQ==
X-Google-Smtp-Source: AJdET5ecfrGKa0L06YsKMhw1U2t4rW9SZOwht/0qBaCmUMMKcoVsSNwe4RVVwOt5cug+qEPO/zdtvQ==
X-Received: by 2002:a63:df13:: with SMTP id u19mr21951076pgg.294.1542667576851;
        Mon, 19 Nov 2018 14:46:16 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id s9sm36111522pgl.88.2018.11.19.14.46.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 14:46:16 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
        (envelope-from <jgg@ziepe.ca>)
        id 1gOsJ5-0008GP-5I; Mon, 19 Nov 2018 15:46:15 -0700
Date:   Mon, 19 Nov 2018 15:46:15 -0700
From:   Jason Gunthorpe <jgg@ziepe.ca>
To:     "Mora, Jorge" <Jorge.Mora@netapp.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
Message-ID: <20181119224615.GM4890@ziepe.ca>
References: <20181119154607.10832.92558.stgit@manet.1015granger.net>
 <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
 <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
 <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
 <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
 <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
 <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
 <4EE34B64-0BEB-439A-B2A2-D77673D4CF70@oracle.com>
 <5EA42399-05C2-40D3-A5CA-7B40971AEC33@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5EA42399-05C2-40D3-A5CA-7B40971AEC33@netapp.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 09:42:56PM +0000, Mora, Jorge wrote:
> Hello Chuck,
> 
> I am confused, is it the whole purpose of RDMA is to place the data
> directly into the memory location given by the virtual address or
> offset? What you are saying is that this offset is not the actual
> memory address and so the driver must map this offset to the actual
> address?

All RDMA on the wire addresses are 'virtual' and always go through
translation hardware to reach a physical memory address. Even if you
have a virtual address that matches your physical address there will
still be translation hardware to enforce security.

The direct placement refers to not copying data, not to using physical
memory addresses throughout the protocol design.

So it is better to use a virtual address that doesn't disclose any
information about the host's configuration to the network, such as
physical locations of kernel memory.

Jason

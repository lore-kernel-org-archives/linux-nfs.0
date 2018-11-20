Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0816C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 03:09:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 68DB320831
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 03:09:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="CcJ6HTdU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68DB320831
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730134AbeKTNgN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 08:36:13 -0500
Received: from mail-pg1-f196.google.com ([209.85.215.196]:38297 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726576AbeKTNgN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 08:36:13 -0500
Received: by mail-pg1-f196.google.com with SMTP id g189so238276pgc.5
        for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2018 19:09:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BgIMCTI0ZD4mfuO+PTzduD0ofGZaiqat0Py5phhCsdE=;
        b=CcJ6HTdUM9YCpbEdecTkoRV/9SJ52ioOsnNzYCYLe19i+6OAH9yCjGnbpod2Sr9vj3
         U+BCPUN+hR2NhKrEkRjBysnYTXUSGe3VQvdVavwSr/lNtWOitQplnjTo3Zn0fYeBVszw
         5fXkcOyZ2SVR6ruDhnUfdvD6726c68zg1WYWJVQuToZJL0jTKAfFmF/K2J/9Ktpx2nUe
         +6elh+bBi/gD1uSfrN5XaLiEOTxJzGtJZVVNZr/og555wVpRUsdpUOHX8z7sTJhrqvDO
         +fCgC2SHy9eAtstV/RBXAULfFC/uuKdAt/2uVoMlczDTltUm5hYPsVs5Zd1XHrYkLLlg
         Ucqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=BgIMCTI0ZD4mfuO+PTzduD0ofGZaiqat0Py5phhCsdE=;
        b=OyOS4DP288wZQduA56FICCPBjJzm+4CP97Hik/jwkSZ6t+awiJJhEazkKuAlxo7Au7
         jrLTlEtYcV2Y/HTcwvE0+UmD8i8qsYh4/AWhzKJlKy/no9nL/lPwzrstngd2ErOtJY8E
         rlRMVg25K9AUtFsmwwWmS5t1P8sPLRXM5LfPHB5LTv0Hqcz8oW2hrtpmHmn9FubPi7rL
         7Jw4PFHcgXlPJXdDKWsiKM81ISmfbxG296OgOPxlMkmg5LmPGAHHo/TT31gyJlZPtbX+
         6NTIMTnCxBmxq5FiMV5Rg8tLD5grY3zX8lWAGjXfQ9xO1tEUMnQ0uU1DS/XupO/e2rZ4
         poEQ==
X-Gm-Message-State: AGRZ1gLfFdf56oYn+6RGA5HZK8yafb41PHkiBLB0SNvfRMupe+JOsm0j
        T7HgpYLv3NhC3tce0g/ecFQNVw==
X-Google-Smtp-Source: AJdET5eAmzm0Nj98PIRWA3UkxwjRg9BU/XeRRmJRhVeanjce9H2f3jJUtX6kKgqaacvSdIzJ4Vva/Q==
X-Received: by 2002:a62:a99:: with SMTP id 25mr327952pfk.121.1542683358134;
        Mon, 19 Nov 2018 19:09:18 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id d65-v6sm63694124pfc.144.2018.11.19.19.09.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 19:09:17 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
        (envelope-from <jgg@ziepe.ca>)
        id 1gOwPc-0001cg-IO; Mon, 19 Nov 2018 20:09:16 -0700
Date:   Mon, 19 Nov 2018 20:09:16 -0700
From:   Jason Gunthorpe <jgg@ziepe.ca>
To:     Tom Talpey <tom@talpey.com>
Cc:     "Mora, Jorge" <Jorge.Mora@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
Message-ID: <20181120030916.GQ4890@ziepe.ca>
References: <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
 <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
 <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
 <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
 <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
 <4EE34B64-0BEB-439A-B2A2-D77673D4CF70@oracle.com>
 <5EA42399-05C2-40D3-A5CA-7B40971AEC33@netapp.com>
 <20181119224615.GM4890@ziepe.ca>
 <d6e65bdf-6cdd-1a23-36de-71aeb57a22e0@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6e65bdf-6cdd-1a23-36de-71aeb57a22e0@talpey.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 09:45:24PM -0500, Tom Talpey wrote:
> On 11/19/2018 5:46 PM, Jason Gunthorpe wrote:
> > On Mon, Nov 19, 2018 at 09:42:56PM +0000, Mora, Jorge wrote:
> > > Hello Chuck,
> > > 
> > > I am confused, is it the whole purpose of RDMA is to place the data
> > > directly into the memory location given by the virtual address or
> > > offset? What you are saying is that this offset is not the actual
> > > memory address and so the driver must map this offset to the actual
> > > address?
> > 
> > All RDMA on the wire addresses are 'virtual' and always go through
> > translation hardware to reach a physical memory address. Even if you
> > have a virtual address that matches your physical address there will
> > still be translation hardware to enforce security.
> > 
> > The direct placement refers to not copying data, not to using physical
> > memory addresses throughout the protocol design.
> > 
> > So it is better to use a virtual address that doesn't disclose any
> > information about the host's configuration to the network, such as
> > physical locations of kernel memory.
> 
> Agreed. And, this is a very subtle but very powerful aspect of FRWR
> registration, that the high-order bits of the "virtual address" can
> basically be any value of the requestor's (client's) choice.
> 
> Note, the low-order bits, up to the maximum offset used by the upper
> layer (e.g. a few MB for NFS), must be reserved in order to allow RDMA
> segments to iterate over the range of bytes in the region. That's only
> 24 or so bits out of the available 64, here however.

Why does it depend on protocol? 

So long as the adaptor can compute VA + Offset = Physical the upper
bits can be changed. For many adaptors that means PAGE_SIZE or huge
page size level alignment..

Jason

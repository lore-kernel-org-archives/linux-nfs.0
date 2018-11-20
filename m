Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2153FC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 03:32:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D1E5B2080C
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 03:32:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="H1w1bofi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E5B2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730065AbeKTN7S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 08:59:18 -0500
Received: from mail-pg1-f196.google.com ([209.85.215.196]:41105 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727688AbeKTN7S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 08:59:18 -0500
Received: by mail-pg1-f196.google.com with SMTP id 70so253252pgh.8
        for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2018 19:32:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=doKDx3ttrKEr5GxHVuw8L9u9oq41WXnpyrDUsIsb/rM=;
        b=H1w1bofiIR/DJlhl/Gg/LwClD2zN7cyXLmlISnSrTho9i6DcOKN7ueYr9Llqzs1vC+
         vkwpHUGM4c/w4Y5GJzXQ7FkBKUCCdzGVKOUCM3YMfNmhZSvbGo7tNxup3aPr82vzIaCy
         ms3Lj2mt110iGQUVNH3vtxDHAOLatSvifonMCTnHmdRuG+lfV8Y657zpgWfaUy7OwiY3
         PdTjjlWGft9UKnwZcTUruLJEmv9oQ/WCvYpxwNiCkzg7M2MT7g84eFrYZnfR/5i9MZGz
         o6Cj7301HQ3GawL9C070arMYOlTvkr3/n6bpIkWav1jghAyD77ZHwtyqzkl7Y30aoPA9
         9vvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=doKDx3ttrKEr5GxHVuw8L9u9oq41WXnpyrDUsIsb/rM=;
        b=HwsRiN5cic5+akDIJITZSzQuZL6swpMdzRd+OpLM3Idv+XfClXCV7snmJdr63y4jWY
         w5dFQugHEhKsd5vfhKy1sAFdJKro6HtHiqXMLrjIFUUP1oducNZRFq4uMeAab1yUEd4R
         OGJjUjtKZvldw/cOrH0r7rrt9gzk3dRbOAVhn2jDjnXTbh9ZHnGMJHJfi9iVZ3DgH95n
         SZO+rNBEq0x/BYtRDRNxn0lHy2Fza3c8Pms3sDXzvNJj1NjfM52IP2gwYY8oCE3QgBt1
         ZlaSpGdosIt3SkYK4IxQ2bpLaP4+JftLE0ALEFLyYIusSEhZgoaw/hPegUJBIgOrSsmT
         vrHA==
X-Gm-Message-State: AGRZ1gKh6pkVijzqU8HDHRRuCjhwpjsYAaNkhe/QLWI3fO7ZqMGVpVHV
        Wtx9s1RJx/zZIvDUn7m7DX6lRg==
X-Google-Smtp-Source: AJdET5eQc7FxbkpNOPxeIsnl1TtFtj44XD+/HuLYMs4ImKoXxgjX4VjLXGvB5BC0iagfZLKslz079Q==
X-Received: by 2002:a62:ab0d:: with SMTP id p13mr406279pff.211.1542684739962;
        Mon, 19 Nov 2018 19:32:19 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id b62-v6sm48524496pfa.159.2018.11.19.19.32.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 19:32:19 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
        (envelope-from <jgg@ziepe.ca>)
        id 1gOwlu-0001mf-Dp; Mon, 19 Nov 2018 20:32:18 -0700
Date:   Mon, 19 Nov 2018 20:32:18 -0700
From:   Jason Gunthorpe <jgg@ziepe.ca>
To:     Tom Talpey <tom@talpey.com>
Cc:     "Mora, Jorge" <Jorge.Mora@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
Message-ID: <20181120033218.GS4890@ziepe.ca>
References: <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
 <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
 <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
 <4EE34B64-0BEB-439A-B2A2-D77673D4CF70@oracle.com>
 <5EA42399-05C2-40D3-A5CA-7B40971AEC33@netapp.com>
 <20181119224615.GM4890@ziepe.ca>
 <d6e65bdf-6cdd-1a23-36de-71aeb57a22e0@talpey.com>
 <20181120030916.GQ4890@ziepe.ca>
 <8fd325fa-290a-6381-80d8-e6ac20acffe8@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8fd325fa-290a-6381-80d8-e6ac20acffe8@talpey.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 10:25:37PM -0500, Tom Talpey wrote:

> Absolutely, but if the offset walks into the high-order invariant bits,
> they won't be invariant any longer. It would still work, but it would
> defeat the wireshark trick that Chuck wants to play.

Sure, OK, if you care about the bits being invarient, and not simply
randomized :)

> > For many adaptors that means PAGE_SIZE or huge
> > page size level alignment..
> 
> I'm not sure I understand this. The FRWR hides the native page size, by
> providing the page frames in the local work request. Their size isn't
> known to the protocol.

Ah, some HW has limitations in how it can construct a VA. In many
implementation the low order bits of the VA must match the offset into
the page. If the page is 4K that is 12 bits, if it is 2M that is 21
bits..

So there should be restrictions on what start VA can be assigned to a
FRWR.

Jason

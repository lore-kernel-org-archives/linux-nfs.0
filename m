Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3777BC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 16:16:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 08C0A20851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 16:16:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08C0A20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729973AbeKTCkm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 21:40:42 -0500
Received: from mail-pf1-f193.google.com ([209.85.210.193]:39017 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729865AbeKTCkm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 21:40:42 -0500
Received: by mail-pf1-f193.google.com with SMTP id c72so10397135pfc.6;
        Mon, 19 Nov 2018 08:16:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UeowSjMkcHcPo4RNiR3cKWf9CD2WHy7CSPdj17dgNJQ=;
        b=Kwh7Ug69R/8RV18sLSCrnP+eMv3VEOZHYa8lc3a6hkSqakF7UM6KNFseW8lVG4I59W
         843W1qlALouDCGasCXxtP9C0IEsC3VLTHkseg2kDRfQMqkelU+00MxlpK1FjjPivObBR
         ObRXzCU/BXMvaNv1WwVHDtxornulc6gYsD7zMJnVxOG4faMPIMUylykEaOTs8AGXFKu3
         /6HfJleMEXbWlBXqtF6kcceXTtaSq2q+ZJzwdvhuPvKZngusqzltw2Q/GsrHoRyELZVF
         caU7fikctSaFDc4W4mKCsLMPpwlNkFWO8xdegIaePSW29JtDiKh9AvUwyBqzxj2WqbHG
         jlRw==
X-Gm-Message-State: AGRZ1gL93zO10yv3XyqTxdYBjZrO8DYvp7KPwl+ZdpH+b62m8RRWPaxO
        gGviPRk7oenjFJWrBYbMibZkvLck
X-Google-Smtp-Source: AJdET5dmKWioC2Kb35wTvQ9j+xA1vozRJPrwmagTMX1m+4I7FNYgo1hSaWOu4eLiY1/vwIMIPWKefA==
X-Received: by 2002:a62:65c3:: with SMTP id z186-v6mr24025833pfb.206.1542644198997;
        Mon, 19 Nov 2018 08:16:38 -0800 (PST)
Received: from ?IPv6:2620:15c:2cd:203:5cdc:422c:7b28:ebb5? ([2620:15c:2cd:203:5cdc:422c:7b28:ebb5])
        by smtp.gmail.com with ESMTPSA id i193sm50606675pgc.22.2018.11.19.08.16.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 08:16:38 -0800 (PST)
Message-ID: <1542644197.185366.50.camel@acm.org>
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
From:   Bart Van Assche <bvanassche@acm.org>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, oulijun@huawei.com, umalhi@cisco.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com
Date:   Mon, 19 Nov 2018 08:16:37 -0800
In-Reply-To: <20181119154551.10832.5498.stgit@manet.1015granger.net>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
         <20181119154551.10832.5498.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-11-19 at 10:45 -0500, Chuck Lever wrote:
+AD4 FMR is not supported on most recent RDMA devices. It is also slower
+AD4 and less secure than FRWR. As discussed during the RDMA BoF at LPC
+AD4 2018, it is time to remove support for FMR in the NFS/RDMA client
+AD4 stack. NFS/RDMA server-side uses either local memory registration or
+AD4 FRWR.  There is no change required there to deprecate FMR.
+AD4 
+AD4 There are a few Infiniband/RoCE devices in the kernel tree that do
+AD4 not support MEM+AF8-MGT+AF8-EXTENSIONS, and therefore will no longer support
+AD4 client-side NFS/RDMA. These are:
+AD4 
+AD4  - mthca
+AD4  - qib
+AD4  - usnic
+AD4  - hns (RoCE)

Can someone from Intel comment on how many of their customers rely on the qib
driver?

Can someone from Cisco comment on how many of their customers rely on the usnic
driver?

Can someone from Huawei comment on how many of their customers rely on the hns
driver?

I'm wondering whether I can remove FMR support from the SRP initiator driver.

Thanks,

Bart.

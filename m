Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 821D3C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 20:52:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4D0DB2075B
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 20:52:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D0DB2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730834AbeKTHRh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 02:17:37 -0500
Received: from mail-pg1-f193.google.com ([209.85.215.193]:38186 "EHLO
        mail-pg1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730797AbeKTHRh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 02:17:37 -0500
Received: by mail-pg1-f193.google.com with SMTP id g189so2639584pgc.5;
        Mon, 19 Nov 2018 12:52:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=c9Owj08DMi5r3BGZlzt16stYjwcSZrTuXq1sknMArz4=;
        b=PAUmrBkKn0E8GNizK8rmC2N0Nn+KNs4xKR2SrFpEdwpH2pcOH4egb1mkOljOU+C5BO
         FJe/yDcj1g4/h6Jo6Mabb5t5Nfz734PgFVW5sLSKdBwjNAZkvFZeV/HaUbl+jlC83oSy
         TI9HA53gBiguP2dYX7imBOcvlRNgUKy6DF6d4ebygDGSXVGni/CXEKahoz02LKXy+lkx
         +xqBwQz8OiBZaDGQFmqBvo+57Jv/eoqOPZ57hyMlnlkkzB/itl2qMLchYw2fD0LqmTUW
         2fgUK9mATN/cjREa6WQM0aEKfPqq3X/XzRvUWPhv25ujra2/of2dCniYo/akwPoKUavY
         LzFA==
X-Gm-Message-State: AGRZ1gJj0hDvODkCJQLVsCGQLaq4mpQiuApoFsrxeyHSRV+i0KfXRodf
        QOWshmYnqwnQBcwhE0Zn2zU=
X-Google-Smtp-Source: AJdET5fxCAYr2qHUuJBX+29oK5lxTpHyHiQ2cnuYVV4s6dRBlPWFg34+DWwm+cGQkQFHvDhe3ppa6g==
X-Received: by 2002:a63:9a09:: with SMTP id o9mr20630778pge.94.1542660732336;
        Mon, 19 Nov 2018 12:52:12 -0800 (PST)
Received: from ?IPv6:2620:15c:2cd:203:5cdc:422c:7b28:ebb5? ([2620:15c:2cd:203:5cdc:422c:7b28:ebb5])
        by smtp.gmail.com with ESMTPSA id m198sm46796388pga.10.2018.11.19.12.52.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Nov 2018 12:52:11 -0800 (PST)
Message-ID: <1542660730.185366.62.camel@acm.org>
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
From:   Bart Van Assche <bvanassche@acm.org>
To:     Leon Romanovsky <leon@kernel.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, oulijun@huawei.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com
Date:   Mon, 19 Nov 2018 12:52:10 -0800
In-Reply-To: <20181119190913.GC21715@mtr-leonro.mtl.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
         <20181119154551.10832.5498.stgit@manet.1015granger.net>
         <1542644197.185366.50.camel@acm.org>
         <20181119190913.GC21715@mtr-leonro.mtl.com>
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-11-19 at 21:09 +-0200, Leon Romanovsky wrote:
+AD4 The more accurate question is +ACI-how many customers ... use latest,
+AD4 upstream kernel?+ACI

Hi Leon,

If this would not be clear: I am in favor of removing kernel drivers that
are no longer in use. Recently I supported a proposal to remove the SCSI
OSD driver from the kernel tree because that driver
probably has not been
used by anyone in the past five years.

But I think that kernel drivers that are still in use should stay in the
kernel tree, no matter which version is in use. Since the Linux kernel ABI
is backwards compatible, with every Linux distro it is possible to replace
the Linux kernel that was provided by the Linux distributor with a more
recent upstream kernel. I think it would be a very unpleasant surprise for
people who use one of the RDMA adapters that only support FMR if they would
test a more recent kernel and if they would notice that its driver has been
removed.

Bart.

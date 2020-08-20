Return-Path: <SRS0=3r48=B6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1265C433DF
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 21:03:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 436872078D
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 21:03:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="nOEpqeCk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726741AbgHTVDC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Aug 2020 17:03:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51226 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726716AbgHTVDB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2020 17:03:01 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BAC14C061385;
        Thu, 20 Aug 2020 14:03:00 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 21B2EC53; Thu, 20 Aug 2020 17:02:59 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 21B2EC53
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1597957379;
        bh=9IfJeCRsn0Fic0IFS7i92deP6xA0a3e2TxsHEo8mN2A=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nOEpqeCkNU92jEH2kgozmY3ZQEtmVED0Awkf7JcxhDpLYbDMuDCssIHI3TOWbmm14
         i8WmYfg/LBRLXU/al9VuxawT8HBAbk4FOjuiK3oK4Nlc4S6lHzNf/3b1WqF/MzWlT6
         Dvvwmp3XXmMrHa8u+j2dI+IJwSU3iq6TeO1zrzkE=
Date:   Thu, 20 Aug 2020 17:02:59 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Miaohe Lin <linmiaohe@huawei.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Convert to use the preferred fallthrough macro
Message-ID: <20200820210259.GE28555@fieldses.org>
References: <20200820025718.51244-1-linmiaohe@huawei.com>
 <01498CCA-B21A-4E8D-9761-41610C54CB9A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01498CCA-B21A-4E8D-9761-41610C54CB9A@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Aug 20, 2020 at 08:49:12AM -0400, Chuck Lever wrote:
> Hi-
> 
> > On Aug 19, 2020, at 10:57 PM, Miaohe Lin <linmiaohe@huawei.com> wrote:
> > 
> > Convert the uses of fallthrough comments to fallthrough macro. Please see
> > commit 294f69e662d1 ("compiler_attributes.h: Add 'fallthrough' pseudo
> > keyword for switch/case use") for detail.
> > 
> > Signed-off-by: Hongxiang Lou <louhongxiang@huawei.com>
> > Signed-off-by: Miaohe Lin <linmiaohe@huawei.com>
> 
> LGTM. If he also approves, I assume Bruce is taking this one for v5.10.

Yep, applying, thanks.--b.

Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90FA2C433F5
	for <linux-nfs@archiver.kernel.org>; Wed, 11 May 2022 12:38:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230293AbiEKMiN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 May 2022 08:38:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44180 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S242499AbiEKMiM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2022 08:38:12 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6BEDE22EA5F;
        Wed, 11 May 2022 05:38:11 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 075D5B82219;
        Wed, 11 May 2022 12:38:10 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 598DFC340F2;
        Wed, 11 May 2022 12:38:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1652272688;
        bh=gyTtKqGrdgmxpfgLM/JIRhyOctz/MqSDCYRh45Yfp+A=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=2deGWEjFIg1VgIh1TKv9PzyymIsk0XV45P65/6KT+7fgWhx/q7J9Z93XxM0lgkI07
         23oYRtnpPjgTC/vPze8yeriSL3XDwctV4KioqFkzfx6dPykma7d+doD/ho8cLanDT/
         ebzYoRmFK85QBoksGCChCTVmfYHC+ERfFLMlwC6k=
Date:   Wed, 11 May 2022 14:38:05 +0200
From:   Greg KH <gregkh@linuxfoundation.org>
To:     Wolfgang Walter <linux@stwm.de>
Cc:     stable@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 5.4.188 and later: massive performance regression with nfsd
Message-ID: <YnuuLZe6h80KCNhd@kroah.com>
References: <f8d9b9112607df4807fba8948ac6e145@stwm.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8d9b9112607df4807fba8948ac6e145@stwm.de>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, May 11, 2022 at 12:03:13PM +0200, Wolfgang Walter wrote:
> Hi,
> 
> starting with 5.4.188 wie see a massive performance regression on our
> nfs-server. It basically is serving requests very very slowly with cpu
> utilization of 100% (with 5.4.187 and earlier it is 10%) so that it is
> unusable as a fileserver.
> 
> The culprit are commits (or one of it):
> 
> c32f1041382a88b17da5736886da4a492353a1bb "nfsd: cleanup
> nfsd_file_lru_dispose()"
> 628adfa21815f74c04724abc85847f24b5dd1645 "nfsd: Containerise filecache
> laundrette"
> 
> (upstream 36ebbdb96b694dd9c6b25ad98f2bbd263d022b63 and
> 9542e6a643fc69d528dfb3303f145719c61d3050)
> 
> If I revert them in v5.4.192 the kernel works as before and performance is
> ok again.
> 
> I did not try to revert them one by one as any disruption of our nfs-server
> is a severe problem for us and I'm not sure if they are related.
> 
> 5.10 and 5.15 both always performed very badly on our nfs-server in a
> similar way so we were stuck with 5.4.
> 
> I now think this is because of 36ebbdb96b694dd9c6b25ad98f2bbd263d022b63
> and/or 9542e6a643fc69d528dfb3303f145719c61d3050 though I didn't tried to
> revert them in 5.15 yet.

Odds are 5.18-rc6 is also a problem?

If so, I'll just wait for the fix to get into Linus's tree as this does
not seem to be a stable-tree-only issue.

thanks,

greg k-h

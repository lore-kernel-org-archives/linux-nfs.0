Return-Path: <SRS0=gmrL=2C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 769DEC04E30
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Dec 2019 04:14:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4C21122B48
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Dec 2019 04:14:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1576124049;
	bh=0mpDmJeRph5V4WCjDlSYPIPApLhVkthD1RCkFHUF3VA=;
	h=Date:From:To:Cc:Subject:Reply-To:References:In-Reply-To:List-ID:
	 From;
	b=lKTO2TJdG2yK0RFdkLMAsjrOjUzbYPMyXNIKgDT7X/yfPYDC8oNgtdabAoGYLPACd
	 v72SBV0QEdTs9a9ef6oqPklkCUzv02dFPv2iSmF93MPlYSRFk+CeeDvFKPZ3e9GdCJ
	 1aHohUnD8AyHhLkGpO46m1KgUcbShQ9vav3GHOI8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727802AbfLLEOI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 Dec 2019 23:14:08 -0500
Received: from mail.kernel.org ([198.145.29.99]:40976 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727795AbfLLEOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Dec 2019 23:14:08 -0500
Received: from paulmck-ThinkPad-P72.home (199-192-87-166.static.wiline.com [199.192.87.166])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8BEF7222C4;
        Thu, 12 Dec 2019 04:14:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1576124047;
        bh=0mpDmJeRph5V4WCjDlSYPIPApLhVkthD1RCkFHUF3VA=;
        h=Date:From:To:Cc:Subject:Reply-To:References:In-Reply-To:From;
        b=mozfCL26QoAKfeRTZyfTvbvLMpiHZ1vFRCq7AxvyzrYYpkR/kLRjWkFpdpH4Q1SLq
         S9zmBnTpnmxEWEdukHa37XDxvNxDqXT9hC7edVpvBe/PYUCHC9dTSFZqOqpwBhsSbl
         7+uYC9+AMMgeimI/nPQiSstsmQ+TMLvtMI9fxCkc=
Received: by paulmck-ThinkPad-P72.home (Postfix, from userid 1000)
        id DEEE5352035F; Wed, 11 Dec 2019 20:14:06 -0800 (PST)
Date:   Wed, 11 Dec 2019 20:14:06 -0800
From:   "Paul E. McKenney" <paulmck@kernel.org>
To:     madhuparnabhowmik04@gmail.com
Cc:     kbuild-all@lists.01.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, joel@joelfernandes.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        rcu@vger.kernel.org, linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [PATCH] fs: nfs: dir.c: Fix sparse error
Message-ID: <20191212041406.GT2889@paulmck-ThinkPad-P72>
Reply-To: paulmck@kernel.org
References: <201912110621.WJ6oENgf%lkp@intel.com>
 <20191211074842.21400-1-madhuparnabhowmik04@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191211074842.21400-1-madhuparnabhowmik04@gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 11, 2019 at 01:18:42PM +0530, madhuparnabhowmik04@gmail.com wrote:
> This build error is because the macro list_tail_rcu() is
> not yet present in the mainline kernel.
> 
> This patch is dependent on the patch : https://lore.kernel.org/linux-kernel-mentees/CAF65HP2SC89k9HJZfcLgeOMRPBKRyasCMiLo2gZgBKycjHuU6A@mail.gmail.com/T/#t

If the NFS folks are OK with it, I would be happy to take it in -rcu,
where the list_tail_rcu() patch is currently located.

							Thanx, Paul

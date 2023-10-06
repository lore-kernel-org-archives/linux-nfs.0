Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A85AEE81DFD
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Oct 2023 13:44:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232439AbjJFNoe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Oct 2023 09:44:34 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33390 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232415AbjJFNod (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Oct 2023 09:44:33 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 39BFE9F;
        Fri,  6 Oct 2023 06:44:32 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0C89C433C8;
        Fri,  6 Oct 2023 13:44:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1696599871;
        bh=ORunLW/Oaj1Bm4rikBaaSgFYbbt8wI4E+XbaUcm298g=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=rkQjGZg/jdQbVETieXcLGsvCGiH7ExyNdbN4nniVHIfMG4rUKrzHzF3iKr0A95ROv
         X/0i1UrxBHcc5xeIkDU1Tw995XMvNmlfF3agzU3SOdScRTOR3G9OCpzael7GkimtgL
         rQyg8B/KbPvDE7ChC3wUd5jvlFnunTLYmeuPPD3iWeLSRYz2jzNj2Zfdq6h1fC3XUH
         3/1TUp/d+YnVLF5vkDCo4kMGmqOBwhXq2+Kt2ETFjk/oipbXuMp41eCQsfNSsBgreS
         SBpsA3cTWbSjy/X9h+/wufyCye8SVuER0ezNNXLoS50d7sah3HlwDqvey+M8EYxjZC
         HEXK1aMffa8Qw==
Date:   Fri, 6 Oct 2023 09:44:30 -0400
From:   Sasha Levin <sashal@kernel.org>
To:     Anna Schumaker <anna@kernel.org>
Cc:     stable@vger.kernel.org, trond.myklebust@hammerspace.com,
        Olga.Kornievskaia@netapp.com, linux-nfs@vger.kernel.org,
        Benjamin Coddington <bcodding@redhat.com>
Subject: Re: [PATCH 1/2] Revert "NFSv4: Retry LOCK on OLD_STATEID during
 delegation return"
Message-ID: <ZSAPPvbkGgXQUP26@sashalap>
References: <5577791deaa898578c8e8f86336eaca053d9efdd.1687890438.git.bcodding@redhat.com>
 <CAFX2JfknBFfB-Ef96DdfiC5wAKp5BJXXoXai+Tz4TxtsbASo2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAFX2JfknBFfB-Ef96DdfiC5wAKp5BJXXoXai+Tz4TxtsbASo2g@mail.gmail.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 05, 2023 at 04:39:58PM -0400, Anna Schumaker wrote:
>Hi Stable Kernel Team,
>
>Can this patch be backported to v6.1+ kernels? The commit id is
>5b4a82a0724a and has been upstream since v6.5. As was mentioned in the
>original patch description (below), the commit being reverted by this
>patch breaks state recovery in a way that is worse than the initial
>bug that it was attempting to fix.

Queued up, thanks!

-- 
Thanks,
Sasha

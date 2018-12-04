Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC19CC04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 22:19:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B72202082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 22:19:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B72202082B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725957AbeLDWS6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 17:18:58 -0500
Received: from ipmail03.adl2.internode.on.net ([150.101.137.141]:47855 "EHLO
        ipmail03.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725875AbeLDWS6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 17:18:58 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 05 Dec 2018 08:48:50 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gUJ1j-0005tt-Ph; Wed, 05 Dec 2018 09:18:47 +1100
Date:   Wed, 5 Dec 2018 09:18:47 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Christoph Hellwig <hch@infradead.org>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 09/11] vfs: push copy_file_ranges -EXDEV checks down
Message-ID: <20181204221847.GQ6311@dastard>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-10-david@fromorbit.com>
 <20181204154347.GA6925@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204154347.GA6925@infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 04, 2018 at 07:43:47AM -0800, Christoph Hellwig wrote:
> Well, this isn't bugfixes anymore, but adding new features..

I made that perfectly clear in the cover description. I called it
twice, one of them explicitly stating that this series made these
infrastructure changes because we have pending functionality that
dependents on cross-device copies being supported in a sane manner.

I'll drop it if you want, but then I'll just have to come back after
all the NFS code is merged and do yet more cleanup work.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

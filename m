Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3366FC04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 21:08:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E9F3020892
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 21:08:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9F3020892
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728411AbeLEVIa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 16:08:30 -0500
Received: from ipmail03.adl6.internode.on.net ([150.101.137.143]:31496 "EHLO
        ipmail03.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727575AbeLEVIa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 16:08:30 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl6.internode.on.net with ESMTP; 06 Dec 2018 07:38:26 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gUePA-0007QF-MF; Thu, 06 Dec 2018 08:08:24 +1100
Date:   Thu, 6 Dec 2018 08:08:24 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Christoph Hellwig <hch@infradead.org>
Cc:     Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 01/11] vfs: copy_file_range source range over EOF should
 fail
Message-ID: <20181205210824.GT6311@dastard>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-2-david@fromorbit.com>
 <CAOQ4uxhOQY8M5rbgHKREN5qpeDGHv0-xK3r37Lj6XfqFoE4qjg@mail.gmail.com>
 <20181204151332.GA32245@infradead.org>
 <20181204212948.GO6311@dastard>
 <20181205141252.GB21109@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205141252.GB21109@infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 05, 2018 at 06:12:52AM -0800, Christoph Hellwig wrote:
> > Realistically, though, I think an attempt to read beyond EOF for the
> > copy should result in behaviour like read() (i.e. return 0 bytes),
> > not EINVAL. The existing behaviour needs to change, though.
> 
> I agree with this statement.  So we don't we implement these semantics?

No, we don't.

I will rework the patch series to make attempts to copy beyond the
end of the source file return 0 to indicate that there is no more
data to copy rather than return an error.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

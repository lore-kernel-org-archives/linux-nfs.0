Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17D62ECDE43
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 02:17:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CA9B320645
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 02:17:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA9B320645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727041AbeJVKd5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 06:33:57 -0400
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:24031 "EHLO
        ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725922AbeJVKd5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 06:33:57 -0400
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 22 Oct 2018 12:47:26 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gEPmW-0002DA-OI; Mon, 22 Oct 2018 13:17:24 +1100
Date:   Mon, 22 Oct 2018 13:17:24 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH 27/28] xfs: remove xfs_reflink_remap_range
Message-ID: <20181022021724.GU6311@dastard>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <154013869100.29026.7543087084546497731.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154013869100.29026.7543087084546497731.stgit@magnolia>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Oct 21, 2018 at 09:18:11AM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Since xfs_file_remap_range is a thin wrapper, move the contents of
> xfs_reflink_remap_range into the shell.  This cuts down on the vfs
> calls being made from internal xfs code.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Sensible enough.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com

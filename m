Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C63EBECDE43
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 04:52:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9766D20644
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 04:52:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9766D20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ZenIV.linux.org.uk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727156AbeJVNJs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 09:09:48 -0400
Received: from zeniv.linux.org.uk ([195.92.253.2]:47156 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726784AbeJVNJs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 09:09:48 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gESCv-0002Mw-OD; Mon, 22 Oct 2018 04:52:49 +0000
Date:   Mon, 22 Oct 2018 05:52:49 +0100
From:   Al Viro <viro@ZenIV.linux.org.uk>
To:     Dave Chinner <david@fromorbit.com>
Cc:     "Darrick J. Wong" <darrick.wong@oracle.com>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
Message-ID: <20181022045249.GP32577@ZenIV.linux.org.uk>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard>
 <20181022043741.GX6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022043741.GX6311@dastard>
User-Agent: Mutt/1.9.1 (2017-09-22)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 03:37:41PM +1100, Dave Chinner wrote:

> Ok, this is a bit of a mess. the patches do not merge cleanly to a
> 4.19-rc1 base kernel because of all the changes to
> include/linux/fs.h that have hit the tree after this. There's also
> failures against Documentation/filesystems/fs.h
> 
> IOWs, it's not going to get merged through the main XFS tree because
> I don't have the patience to resolve all the patch application
> failures, then when it comes to merge make sure all the merge
> failures end up being resolved correctly.
> 
> So if I take it through the XFS tree, it will being a standalone
> branch based on 4.19-rc8 and won't hit linux-next until after the
> first XFS merge when I can rebase the for-next branch...

How many conflicts does it have with XFS tree?  I can take it via
vfs.git...

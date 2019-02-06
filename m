Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57DC6C169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 20:39:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2B2662083B
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 20:39:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726565AbfBFUjP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 15:39:15 -0500
Received: from fieldses.org ([173.255.197.46]:54340 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726022AbfBFUjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Feb 2019 15:39:15 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C82D01C8A; Wed,  6 Feb 2019 15:39:14 -0500 (EST)
Date:   Wed, 6 Feb 2019 15:39:14 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v1] svcrdma: Remove max_sge check at connect time
Message-ID: <20190206203914.GD26258@fieldses.org>
References: <154845326910.67269.13122816140536911275.stgit@seurat.1015granger.net>
 <20190126224419.GC24528@fieldses.org>
 <20E2C34D-C219-47AD-9688-69201E4162A8@oracle.com>
 <617D3968-4915-4121-8190-90B7752234DB@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <617D3968-4915-4121-8190-90B7752234DB@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 06, 2019 at 11:57:12AM -0500, Chuck Lever wrote:
> > On Jan 26, 2019, at 10:43 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> Thanks!  Do you think this is suitable for 5.0 and stable, or should I
> >> save it up for 5.1?
> > 
> > Don would like to see it in 5.0 and stable.
> 
> Hi Bruce, is this fix going to v5.0-rc ?

Thanks for the reminder.  For 5.0, I've got this and the copy
error-return fix from Trond; I'll send a pull request tomorrow.

--b.

Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E243EC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 16:11:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BAE9A206DF
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 16:11:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729136AbfDBQLR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 12:11:17 -0400
Received: from fieldses.org ([173.255.197.46]:56950 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726792AbfDBQLR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 12:11:17 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 8209B1D39; Tue,  2 Apr 2019 12:11:16 -0400 (EDT)
Date:   Tue, 2 Apr 2019 12:11:16 -0400
To:     "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: directory delegations
Message-ID: <20190402161116.GA2828@fieldses.org>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 01, 2019 at 12:21:49PM -0400, Bradley C. Kuszmaul wrote:
> Hi, I'm the architect for Oracle's File Storage Service.   FSS is
> basically a big scalable NFS server that runs in Oracle's cloud.
> 
> Our metadata operations have higher latency than a vanilla NFS
> server (e.g., a Linux NFS server serving a XFS stored on a block
> device), and we suspect that directory delegations would make a big
> performance improvement.
> 
> I understand, however, that essentially no one implements directory
> delegations.
> 
> Can anyone fill me in on the current thinking of the future of
> support for directory delegations in the Linux NFS client?

Maybe somebody else will speak up, but I don't know of any effort to
implement directory delegations.

What metadata operations specifically are you worried about?  The
directory delegations that are specified in RFC 5661 are read-only.
Which might explain some of the lack of interest.

But there may be other steps that we could take to improve matters.

--b.

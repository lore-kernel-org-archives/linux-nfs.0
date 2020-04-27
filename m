Return-Path: <SRS0=uE3C=6L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BDFCC4CECD
	for <linux-nfs@archiver.kernel.org>; Mon, 27 Apr 2020 18:39:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E9532214D8
	for <linux-nfs@archiver.kernel.org>; Mon, 27 Apr 2020 18:39:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726476AbgD0Sjl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 27 Apr 2020 14:39:41 -0400
Received: from fieldses.org ([173.255.197.46]:36466 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725995AbgD0Sjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Apr 2020 14:39:41 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id EA0BE40B5; Mon, 27 Apr 2020 14:39:40 -0400 (EDT)
Date:   Mon, 27 Apr 2020 14:39:40 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     trondmy@kernel.org
Cc:     Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] mountd: Ignore transient and non-fatal filesystem
 errors in nfsd_fh()
Message-ID: <20200427183940.GF31277@fieldses.org>
References: <20200416221252.82102-1-trondmy@kernel.org>
 <20200416221252.82102-2-trondmy@kernel.org>
 <20200416221252.82102-3-trondmy@kernel.org>
 <20200416221252.82102-4-trondmy@kernel.org>
 <20200416221252.82102-5-trondmy@kernel.org>
 <20200416221252.82102-6-trondmy@kernel.org>
 <20200416221252.82102-7-trondmy@kernel.org>
 <20200427183844.GE31277@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200427183844.GE31277@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ack to the series, otherwise, looks good.--b.

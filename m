Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D935C04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 10:13:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48D2A214E0
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 10:13:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D2A214E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728003AbeLEKNK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 05:13:10 -0500
Received: from foss.arm.com ([217.140.101.70]:51184 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727838AbeLEKNK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Dec 2018 05:13:10 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 01DA080D;
        Wed,  5 Dec 2018 02:13:10 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.113])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E658A3F575;
        Wed,  5 Dec 2018 02:13:08 -0800 (PST)
Date:   Wed, 5 Dec 2018 10:13:06 +0000
From:   Catalin Marinas <catalin.marinas@arm.com>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Cristian Marussi <cristian.marussi@arm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix RPC receive hangs
Message-ID: <20181205101306.GA16534@arrakis.emea.arm.com>
References: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 04, 2018 at 02:24:39PM -0500, Trond Myklebust wrote:
> The RPC code is occasionally hanging when the receive code fails to
> empty the socket buffer due to a partial read of the data. When we
> convert that to an EAGAIN, it appears we occasionally leave data in the
> socket. The fix is to just keep reading until the socket returns
> EAGAIN/EWOULDBLOCK.
> 
> Reported-by: Catalin Marinas <catalin.marinas@arm.com>
> Reported-by: Cristian Marussi <cristian.marussi@arm.com>
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

It seems to do the trick for me. Thanks.

Tested-by: Catalin Marinas <catalin.marinas@arm.com>

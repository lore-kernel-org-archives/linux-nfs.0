Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22A73C10F0B
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 02:07:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1A3E206B8
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 02:07:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726130AbfDCCHv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 22:07:51 -0400
Received: from fieldses.org ([173.255.197.46]:57372 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726089AbfDCCHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 22:07:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id B420D14DB; Tue,  2 Apr 2019 22:07:50 -0400 (EDT)
Date:   Tue, 2 Apr 2019 22:07:50 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bradley.kuszmaul@oracle.com" <bradley.kuszmaul@oracle.com>
Subject: Re: directory delegations
Message-ID: <20190403020750.GA8272@fieldses.org>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org>
 <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org>
 <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
> The create itself needs to be sync, but the attribute delegations mean
> that the client, not the server, is authoritative for the timestamps.
> So the client now owns the atime and mtime, and just sets them as part
> of the (asynchronous) delegreturn some time after you are done writing.
> 
> Were you perhaps thinking about this earlier proposal? 
> https://tools.ietf.org/html/draft-myklebust-nfsv4-unstable-file-creation-01

That's it, thanks!

Bradley is concerned about performance of something like untar on a
backend filesystem with particularly high-latency metadata operations,
so something like your unstable file createion proposal (or actual write
delegations) seems like it should help.

--b.

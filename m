Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B13B7C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 19:41:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 803672070D
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 19:41:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727460AbfDBTls (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 15:41:48 -0400
Received: from fieldses.org ([173.255.197.46]:57114 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727065AbfDBTls (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 15:41:48 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3AFB91D39; Tue,  2 Apr 2019 15:41:48 -0400 (EDT)
Date:   Tue, 2 Apr 2019 15:41:48 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Cc:     linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>
Subject: Re: directory delegations
Message-ID: <20190402194148.GA5269@fieldses.org>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 02, 2019 at 01:26:19PM -0400, Bradley C. Kuszmaul wrote:
> My simple model of metadata operations is to untar something like
> the linux sources.
> 
> Each file incurs a LOOKUP, CREATE, SETATTR, and WRITE, each of which
> is fairly high latency (even the WRITE ends up being done
> essentially synchronously because tar closes the file after its
> write(2) call.)

An ordinary file write delegation can help with some of that.

> I guess directory delegations might save the cost of LOOKUP.
> 
> Is there any hope for getting write delegations?
> 
> What other steps might be possible?

Trond, wasn't there a draft describing your idea that a server should be
able to grant a write delegation on create and delay the sync?  I can't
find it right now.

--b.

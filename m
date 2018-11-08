Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D290ECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 15:31:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DED8420825
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 15:31:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DED8420825
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726781AbeKIBHi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 20:07:38 -0500
Received: from fieldses.org ([173.255.197.46]:38568 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726774AbeKIBHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 20:07:37 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9618C207B; Thu,  8 Nov 2018 10:31:36 -0500 (EST)
Date:   Thu, 8 Nov 2018 10:31:36 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Ben Greear <greearb@candelatech.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Support for VRF in NFS?
Message-ID: <20181108153136.GA4947@fieldses.org>
References: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
 <20181108011429.GC30776@fieldses.org>
 <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Nov 07, 2018 at 09:08:16PM -0800, Ben Greear wrote:
> 
> 
> On 11/07/2018 05:14 PM, J. Bruce Fields wrote:
> >On Tue, Nov 06, 2018 at 01:03:54PM -0800, Ben Greear wrote:
> >>Hello,
> >>
> >>I made a stab at implementing VRF support in NFS, but it appears
> >>fairly complicated and I ended up reverting my changes....
> >>
> >>Is anyone working on this?
> >>
> >>And, if not, if anyone would like to be sponsored to work on this, please
> >>let me know.
> >
> >Um, sorry--what's VRF?
> 
> Virtual Router logic.  It is sort of like network stack containers,
> and has been solid and fully featured in the kernel since 4.16 or so.
> 
> In the end, you effectively need to call the logic that SO_BINDTODEVICE
> calls on the socket before binding to an IP.
> 
> The NFS and RPC logic is a giant tangled mess to my eyes, so
> hoping I could bribe someone else to do it :)

So it's not enough to support network namespaces?

What's your motivation for this?

--b.

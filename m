Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CFBAC433ED
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Apr 2021 19:34:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CC612613F8
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Apr 2021 19:34:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238676AbhD0Tfh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Apr 2021 15:35:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38028 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235686AbhD0Tfh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2021 15:35:37 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BB438C061574
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2021 12:34:53 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id D5221727A; Tue, 27 Apr 2021 15:34:52 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org D5221727A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1619552092;
        bh=UhjwvtsU6u0t72fow5cgVYWV3iiJ56t/9Ejhj5CIDXg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=txp6R7tyowTzW1RM7G75NbdgtYEz/bjHFfjVZmCrrkgyUA9ST4Q4qbXUOW9OA5G7U
         6Jq/OYLvHkAB9VaMDhuXXs5B29O+D73EpEdPhQw1gmfMyHLukxMPw3T0+/A2bT5+ph
         GxsPxM7orcuT7A7qHu80P2VlHnAN7RZAw7Qc/uIs=
Date:   Tue, 27 Apr 2021 15:34:52 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Rogier Wolff <R.E.Wolff@BitWizard.nl>
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: Lockd error message is unclear.
Message-ID: <20210427193452.GA11361@fieldses.org>
References: <20210427190311.cjjzeded7hl3fkew@BitWizard.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210427190311.cjjzeded7hl3fkew@BitWizard.nl>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 27, 2021 at 09:03:11PM +0200, Rogier Wolff wrote:
> 
> Hi, 
> 
> Two things..... 
> 
> I got: 
> 
>    lockd: cannot monitor <client> 
> 
> in the logfile and the client was terrily slow/not working at all.
> 
> everything pointed to a lockd problem... 
> 
> In the end... it turns out that my rpc.statd stopped working.  I had
> to go and download the sources to figure this out... I would firstly
> suggest to improve the error message to give others running into this
> more hints as to where to look.
> 
> The erorr message on line 169 of lockd.c could read: 
> 
> 	lockd: Error in the rpc to rpc.statd to monitor %s\n
> 
> Would it be an idea to print the res.status error code? 

I'm not sure about the wording, but including the error code sounds like
a good idea.  (Would that have made a difference in your case?)

> That said... 
> 
> When this situation is going on, the client grinds to a halt, and
> lockd seems "stuck" in D state. I tried killing or stracing it, to try
> to clear the error, before I found out it is a kernel deamon...
> 
> When this failure happens, I get the impression that lockd keeps on
> trying to be "of service", retrying operations that are bound to
> fail. So maybe the error should be cached, and then immediately
> handled instead of making the client grind to a halt. (it is the (one
> second?) timeout in nsm_mon_unmon and the big backlog of requests that
> result in the same call and timeout that frustrate the client... )

The -ECONNREFUSED case?

I'm not sure why it retries there.  Maybe just to allow stopping and
starting rpc.statd (e.g. for upgrades) without failing operations?

--b.

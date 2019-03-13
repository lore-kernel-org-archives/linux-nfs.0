Return-Path: <SRS0=eK3I=RQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 278EEC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Mar 2019 14:56:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F11BA21019
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Mar 2019 14:56:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726339AbfCMO4B (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Mar 2019 10:56:01 -0400
Received: from fieldses.org ([173.255.197.46]:58562 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725870AbfCMO4B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Mar 2019 10:56:01 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C07421C84; Wed, 13 Mar 2019 10:56:00 -0400 (EDT)
Date:   Wed, 13 Mar 2019 10:56:00 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH 0/3] a few fixes
Message-ID: <20190313145600.GB14717@fieldses.org>
References: <20190311154951.6144-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311154951.6144-1-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Mar 11, 2019 at 11:49:48AM -0400, Scott Mayhew wrote:
> The first patch fixes bogus DESTROY_SESSION and DESTROY_CLIENTID ops
> being sent to the server.  The other two prevent session and client
> records from hanging around on the server.

Thanks!  All three applied.--b.

> 
> Scott Mayhew (3):
>   nfs4.1: don't cache sessionids and clientids after destroying
>   nfs4.1: clean up the session and client created in
>     Environment.finish()
>   nfs4.1: close the file created in SEQ10b
> 
>  nfs4.1/server41tests/environment.py | 4 ++++
>  nfs4.1/server41tests/st_sequence.py | 5 ++++-
>  2 files changed, 8 insertions(+), 1 deletion(-)
> 
> -- 
> 2.17.2

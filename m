Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E7E0C433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 17:25:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 737A761A16
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 17:25:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229662AbhCYRZP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Mar 2021 13:25:15 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33296 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229508AbhCYRZD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Mar 2021 13:25:03 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 631B2C06174A
        for <linux-nfs@vger.kernel.org>; Thu, 25 Mar 2021 10:25:03 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 57E116A45; Thu, 25 Mar 2021 13:25:01 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 57E116A45
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1616693101;
        bh=jQgkpMjw/YlnqpHQD2AO9mY+cpxryaafKB5jR7+dhyE=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=dPJhwkzkajNbcRQ+hVyDuOzSWtz+wPiIXhIwh/UIbsaHwvPGTysRgO+FAN3BkK9gm
         vbpdFr0P/gbmrP5WFKWA3zevC4PF2T3TYS2E26GUIasoxnNBzlISYvpl/TyRyNxHc+
         O59YFlPV1rZWZ+6aWuVwDqKff2moOtU9WWw0UBxs=
Date:   Thu, 25 Mar 2021 13:25:01 -0400
To:     Calum Mackay <calum.mackay@oracle.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] add another courteous server test
Message-ID: <20210325172501.GA16485@fieldses.org>
References: <20210324014630.2454-1-calum.mackay@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210324014630.2454-1-calum.mackay@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks!--b.

On Wed, Mar 24, 2021 at 01:46:28AM +0000, Calum Mackay wrote:
> This adds a second test of courteous server functionality.
> 
>  nfs4.1/server41tests/st_courtesy.py | 44 +++++++++++++++++++++++++++++---
>  1 file changed, 40 insertions(+), 4 deletions(-)
> 
> Calum Mackay (2):
>       pynfs: courtesy: use a helper function to prepare the lock op args
>       pynfs: courtesy: add a test to ensure server releases state appropriately
> 
> 

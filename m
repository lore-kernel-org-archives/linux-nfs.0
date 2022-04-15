Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE128C433EF
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Apr 2022 19:54:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240476AbiDOT4b (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Apr 2022 15:56:31 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57806 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235878AbiDOT4b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2022 15:56:31 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 16808652FB
        for <linux-nfs@vger.kernel.org>; Fri, 15 Apr 2022 12:54:01 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id EA70B6CD0; Fri, 15 Apr 2022 15:53:59 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org EA70B6CD0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1650052439;
        bh=qwEUIfyOmM5rRRjw9teu0AXWQFmhNCgoTMNnYCNb9Hg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=HDY5f1htFwjaY0eKbrLoLm5n4+iYFT1O8aoSgzVA1iKeQP9w4Q6Zq/iUEQBuI5KZ+
         nNEzFfUpecAcYBNiCvdOEtpT61Z28fpC3K9kFjlXzqsShJhfc+pJ3jd9Ri4plQOBim
         8MUCKp7/hJQYrqz5rHLmaSdKPdzrxXfExw9vr3W4=
Date:   Fri, 15 Apr 2022 15:53:59 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     dai.ngo@oracle.com
Cc:     Chuck Lever III <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v19 06/11] NFSD: Update find_clp_in_name_tree() to
 handle courtesy client
Message-ID: <20220415195359.GA28358@fieldses.org>
References: <1648742529-28551-1-git-send-email-dai.ngo@oracle.com>
 <1648742529-28551-7-git-send-email-dai.ngo@oracle.com>
 <20220401152109.GB18534@fieldses.org>
 <52CA1DBC-A0E2-4C1C-96DF-3E6114CDDFFD@oracle.com>
 <8dc762fc-dac8-b323-d0bc-4dbeada8c279@oracle.com>
 <20220413125550.GA29176@fieldses.org>
 <fae06919-13de-9ebb-8259-108f6e18c801@oracle.com>
 <eaf758e8-077d-f7fe-1e02-cfaa49830d97@oracle.com>
 <20220415151959.GA24358@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220415151959.GA24358@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 15, 2022 at 11:19:59AM -0400, Bruce Fields wrote:
> On Fri, Apr 15, 2022 at 07:56:06AM -0700, dai.ngo@oracle.com wrote:
> > On 4/15/22 7:47 AM, dai.ngo@oracle.com wrote:
> > >From user space, how do we force the client to use the delegation
> > >state to read the file *after* doing a close(2)?
> > 
> > I guess we can write new pynfs test to do this, but I'd like to avoid
> > it if possible.
> 
> Right, this would require pynfs tests.  If you don't think they'd be
> that bad.

(Sorry, I meant to write "I don't think they'd be that bad"!  Anyway.)

> But if you don't want to do tests for each step I think
> that's not the end of the world, up to you.
> 
> --b.

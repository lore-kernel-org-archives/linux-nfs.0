Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1AFEC04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 22:36:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9F0212081D
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 22:36:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F0212081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725751AbeLBJty (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 04:49:54 -0500
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:9439 "EHLO
        ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725748AbeLBJty (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 04:49:54 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl2.internode.on.net with ESMTP; 02 Dec 2018 09:06:18 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTDs1-0001LN-L7; Sun, 02 Dec 2018 09:36:17 +1100
Date:   Sun, 2 Dec 2018 09:36:17 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Matthew Wilcox <willy@infradead.org>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
Message-ID: <20181201223617.GR19305@dastard>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com>
 <20181201211806.GO10377@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181201211806.GO10377@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 01, 2018 at 01:18:06PM -0800, Matthew Wilcox wrote:
> On Fri, Nov 30, 2018 at 03:03:39PM -0500, Olga Kornievskaia wrote:
> > Relax the condition that input files must be from the same
> > file systems.
> 
> > +	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> > +			count > MAX_RW_COUNT ? MAX_RW_COUNT : count, 0);
> 
> Wasn't there a concern about splicing between filesystems with different
> block sizes mentioned the last time this came up?  I can't find a citation
> for that now.

the filesystems should be able to handle that themselves - they are
just passes an iter that has a range of data regions in pages that
they copy the required data into/out of. The data transfer mechanism
itself is completely independent of filesystem block sizes....

There's lots of other problems with do_splice_direct, but I don't
think this is one of them. I coul dbe wrong - this code has pretty
much zero documentation on how it is supposed to work and what it is
supposed to do - so don't take my word for it...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

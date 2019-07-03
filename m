Return-Path: <SRS0=RxI+=VA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF5DBC0650E
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Jul 2019 16:43:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4E672189E
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Jul 2019 16:43:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726473AbfGCQna (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Jul 2019 12:43:30 -0400
Received: from mx1.redhat.com ([209.132.183.28]:48284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725847AbfGCQna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Jul 2019 12:43:30 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0E1B6308424C;
        Wed,  3 Jul 2019 16:43:25 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-123-62.rdu2.redhat.com [10.10.123.62])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C711517B40;
        Wed,  3 Jul 2019 16:43:24 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id A61781803CA; Wed,  3 Jul 2019 12:43:23 -0400 (EDT)
Date:   Wed, 3 Jul 2019 12:43:23 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Paul Menzel <pmenzel@molgen.mpg.de>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Chris Tracy <ctracy@engr.scu.edu>, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, it+linux-nfs@molgen.mpg.de
Subject: Re: [PATCH] nfsd: Fix overflow causing non-working mounts on 1 TB
 machines
Message-ID: <20190703164323.GC23076@parsley.fieldses.org>
References: <20190702165107.93C8A2067CFDD@mx.molgen.mpg.de>
 <8c3e0249-b17f-4bd2-4a46-afd4d35f4763@molgen.mpg.de>
 <0b5fdd56-d570-c787-cd56-7e6d0ba65225@molgen.mpg.de>
 <860b4d19-49bd-5d76-aa06-c2d9aeffb452@molgen.mpg.de>
 <17f8948d-19b9-beac-cab1-e4bc587d9612@molgen.mpg.de>
 <20190703155634.GB23076@parsley.fieldses.org>
 <267fb3de-fe3b-fb42-1cc1-3faea5d19d93@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <267fb3de-fe3b-fb42-1cc1-3faea5d19d93@molgen.mpg.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 03 Jul 2019 16:43:30 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jul 03, 2019 at 06:03:06PM +0200, Paul Menzel wrote:
> Dear Bruce,
> 
> 
> On 7/3/19 5:56 PM, J. Bruce Fields wrote:
> > Good catch!  And thanks for the detailed explanation.  Applying for 5.2
> > and stable.
> 
> Thanks. Please note, that in the last part are some guesses, and I am not
> well versed in the terminology. So please feel free to reword the commit
> messages.

I haven't checked all the arithmetic, but it sounds pretty plausible to
me, and clearly that type was wrong.

--b.

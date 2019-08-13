Return-Path: <SRS0=3Ktc=WJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2530C32750
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Aug 2019 17:00:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA5EA2067D
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Aug 2019 17:00:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726785AbfHMRA5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Aug 2019 13:00:57 -0400
Received: from mx2.math.uh.edu ([129.7.128.33]:40622 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726637AbfHMRA4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Aug 2019 13:00:56 -0400
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1hxaAJ-0005LT-1p
        for linux-nfs@vger.kernel.org; Tue, 13 Aug 2019 12:00:56 -0500
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id F1CFE801554; Tue, 13 Aug 2019 12:00:54 -0500 (CDT)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Subject: Re: Regression in 5.1.20: Reading long directory fails
References: <ufak1bhyuew.fsf@epithumia.math.uh.edu>
Date:   Tue, 13 Aug 2019 12:00:54 -0500
In-Reply-To: <ufak1bhyuew.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Tue, 13 Aug 2019 10:08:55 -0500")
Message-ID: <ufazhkdxant.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

To follow up, I built 5.1.20 with just commit
3536b79ba75ba44b9ac1a9f1634f2e833bbb735c reverted and I can now get a
listing of that directory without error.  Since it's a revert of
something else, and this is a new problem, I wonder if the revert went
awry or if something else came to depend on the behavior which was
reverted.  Again, I'm happy to provide any debugging information you
might request.

Also note that the problem persists in 5.2.8.  I see Fedora has a 5.3.0
rc4 build going, so I'll test that one as soon as it finishes.

 - J<

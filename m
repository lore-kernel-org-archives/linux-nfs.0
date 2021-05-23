Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78165C47080
	for <linux-nfs@archiver.kernel.org>; Sun, 23 May 2021 19:14:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3ED55610A6
	for <linux-nfs@archiver.kernel.org>; Sun, 23 May 2021 19:14:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231893AbhEWTQH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 May 2021 15:16:07 -0400
Received: from mx2.suse.de ([195.135.220.15]:36118 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231887AbhEWTQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 May 2021 15:16:06 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1621797279;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=hlAhOG1Kncl3nGsQyF+QEu+HZYrqaMEBEIhnPmLz2Dg=;
        b=l/7xO6s/ONa36uY2hF3geoKfyppNACNvkn1GjEA9KpoHOi68slocEM+2xjc+4NUd1dVCKp
        QWlGpKqDLqFHSpCM2AAU1sRCsBKH36Y1MoGdn+uzIs95nR5jku2jO/5shIbj1LUmmlqm+h
        T+uuNISRFm6VS/5qaEcuLOD5v9DOaQ4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1621797279;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=hlAhOG1Kncl3nGsQyF+QEu+HZYrqaMEBEIhnPmLz2Dg=;
        b=6aiSEvG1V+xagLEYXE3y18+uNeD+8Srg/B752Taq6f02GGJUQOm2MGY8P0sHpcpRMFpeGF
        qSSeFP+KXYD/ZgCQ==
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 40831AC87;
        Sun, 23 May 2021 19:14:39 +0000 (UTC)
Date:   Sun, 23 May 2021 21:14:37 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org, Yong Sun <yosun@suse.com>
Subject: Re: pynfs: COUR2, EID50 test failures
Message-ID: <YKqpnXjGP+Ub0lB0@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <YKdXZa6Izs7kqgfE@pevik>
 <YKf+a7e4lv2BwBBQ@pick.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <YKf+a7e4lv2BwBBQ@pick.fieldses.org>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> On Fri, May 21, 2021 at 08:47:01AM +0200, Petr Vorel wrote:
> > Hi Bruce,

> > what's wrong with pynfs COUR2, EID50 tests?
> > They're failing on various kernels.
> > I got these failures on 5.11.12 (openSUSE package), 5.13.0-rc2 (mainline on
> > openSUSE), 4.9.0 (Debian package):

> > COUR2    st_courtesy.testLockSleepLock                            : FAILURE
> >            OP_OPEN should return NFS4_OK, instead got
> >            NFS4ERR_GRACE

> Are you running it immediately after starting the server?  If so, that's
> expected.  Personally my test scripts mount the server and create a file
> there before running pynfs tests.  The create won't return until the
> grace period's done.
Thanks for info, I'll test that!

> Might be worth documenting in the README, or teaching pynfs to wait
> before running tests.
Or maybe test should create a test file before? That might be faster than waiting.
Because there is some wait for 2 min as part of testing.

> > EID50    st_exchange_id.testSSV                                   : FAILURE
> >            nfs4lib.NFS4Error: OP_EXCHANGE_ID should return
> >            NFS4_OK, instead got NFS4ERR_ENCR_ALG_UNSUPP

> > Nothing in dmesg (tested with "rpcdebug -m nfsd -s lockd").
> > Or is it just my wrong setup?

> SSV support is optional.  We should probably drop the "all" tag from
> that test.
Again, thanks for info. It'd be great if you implement that.

Kind regards,
Petr

> --b.


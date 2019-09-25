Return-Path: <SRS0=I3JF=XU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE3ECC432C2
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Sep 2019 20:07:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A62B72146E
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Sep 2019 20:07:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390416AbfIYUHY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Sep 2019 16:07:24 -0400
Received: from fieldses.org ([173.255.197.46]:60862 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732726AbfIYUHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Sep 2019 16:07:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C12F9150F; Wed, 25 Sep 2019 16:07:23 -0400 (EDT)
Date:   Wed, 25 Sep 2019 16:07:23 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Kevin Vasko <kvasko@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 client locks up on larger writes with Kerberos enabled
Message-ID: <20190925200723.GA11954@fieldses.org>
References: <CAMd28E-pJp4=kvp62FJqGLZo-jGA2rH2OT6-hK_N=TvMiJuT2A@mail.gmail.com>
 <20190925164831.GA9366@fieldses.org>
 <57192382-86BE-4878-9AE0-B22833D56367@oracle.com>
 <CAMd28E-zcjuCfVbDCra4Av3Ewsdd-Ai=E0j3tF2GKJ8P6nG8=w@mail.gmail.com>
 <FCAD9EFD-26AD-41F0-BCCA-80E475219731@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FCAD9EFD-26AD-41F0-BCCA-80E475219731@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Sep 25, 2019 at 11:49:14AM -0700, Chuck Lever wrote:
> Sounds like the NFS server is dropping the connection. With
> GSS enabled, that's usually a sign that the GSS window has
> overflowed.

Would that show up in the rpc statistics on the client somehow?

In that case--I seem to remember there's a way to configure the size of
the client's slot table, maybe lowering that (decreasing the number of
rpc's allowed to be outstanding at a time) would work around the
problem.

Should the client be doing something different to avoid or recover from
overflows of the gss window?

--b.

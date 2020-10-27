Return-Path: <SRS0=QBgL=EC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64189C4363A
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Oct 2020 20:05:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DC8942224E
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Oct 2020 20:05:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="kWjl6XiR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1830854AbgJ0UFO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Oct 2020 16:05:14 -0400
Received: from fieldses.org ([173.255.197.46]:45786 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1830849AbgJ0UFK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Oct 2020 16:05:10 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id DD71328E4; Tue, 27 Oct 2020 16:05:07 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org DD71328E4
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1603829107;
        bh=2NOHR6y3/3UamT1kaF1qHn3lBFLrHG5S9I1ljkCPflc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=kWjl6XiRofb91St3SMTAYKU7RGzjcUkbCVD+a0GxUGFFuWpU3egPlcaIeybbIu+iN
         QUgHIzwmc0N7RYDEHAxhWQ+QXN3Dsw/37U3QYKESsJ/AOiE2qwE3LwOsqc1Ps8nLLl
         JNSFn7wo7Hohv4+5OriC7ecZrwqHgxuucKxazyzk=
Date:   Tue, 27 Oct 2020 16:05:07 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Anna Schumaker <schumakeranna@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jorge Mora <jmora1300@gmail.com>
Subject: Re: xfstests generic/263
Message-ID: <20201027200507.GD1644@fieldses.org>
References: <20201027174945.GC1644@fieldses.org>
 <CAFX2Jf=-Y905+cMtLike2ddpthCV=K6CM8iS4EPeAz1RYzF-pA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFX2Jf=-Y905+cMtLike2ddpthCV=K6CM8iS4EPeAz1RYzF-pA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 27, 2020 at 03:59:56PM -0400, Anna Schumaker wrote:
> On Tue, Oct 27, 2020 at 1:49 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Generic/263 is failing whenever client and server both supports
> > READ_PLUS.
> >
> > I'm not even sure the failure is wrong.  The NFS FALLOC operation doesn't
> > support those other other fallocate modes, are they implemented elsewhere in
> > the kernel or libc somehow?  Anyway, odd that it would have anything to do with
> > READ_PLUS.
> 
> I just ran xfstests, and I'm seeing this too. The test passes using
> basic READ on v4.2, so there might be something farther down the log
> that diff is cutting off. I'll see if anything sticks out to me this
> week.

Thanks!

Also, wireshark doesn't seem to be parsing READ_PLUS replies correctly.
Cc'ing Jorge since he seems to have been the last to touch that code.

--b.

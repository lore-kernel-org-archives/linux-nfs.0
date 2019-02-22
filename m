Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B59C1C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:40:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7E784206B6
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:40:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726152AbfBVUkB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 15:40:01 -0500
Received: from fieldses.org ([173.255.197.46]:53916 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725832AbfBVUkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 15:40:00 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 837331E29; Fri, 22 Feb 2019 15:40:00 -0500 (EST)
Date:   Fri, 22 Feb 2019 15:40:00 -0500
To:     Patrick Steinhardt <ps@pks.im>
Cc:     linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH 1/3] configure.ac: more carefully detect availability of
 res_querydomain(3)
Message-ID: <20190222204000.GB16191@fieldses.org>
References: <a6f2aaea93c1293e62d5109b10d47a7675a45393.1549290423.git.ps@pks.im>
 <20190222075202.GA13960@ncase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222075202.GA13960@ncase>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 08:52:02AM +0100, Patrick Steinhardt wrote:
> On Mon, Feb 04, 2019 at 03:31:18PM +0100, Patrick Steinhardt wrote:
> > Since glibc 2.2, the function res_querydomain(3) is implemented as a
> > define to `__res_querydomain`. Due to this implementation detail, using
> > `AC_CHECK_LIB` with a symbol name of "res_querydomain" will cause a
> > linking failure and thus fail to detect its availability. This is why
> > right now, we try to detect availability of `__res_querydomain` instead.
> > 
> > Unfortunately, this may break on other platforms where there is no
> > `__res_querydomain` but only the function without leading underscores.
> > To fix this, we can perform another `AC_CHECK_LIB([resolv],
> > [res_querydomain], ...)` call in case where the other one was not found
> > and only raise an error if both symbols weren't found.
> > 
> > Signed-off-by: Patrick Steinhardt <ps@pks.im>
> 
> Is there anything I can do to get this rolling and improve my
> patches? Or did I accidentally pick the wrong mailing list for
> the userspace part of nfs?

This is the right mailing list.  Steve Dickson is the nfs-utils
maintainer, it's probably a good idea to include him directly as well,
sometimes people miss stuff on the list.

--b.

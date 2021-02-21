Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 148E9C433DB
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Feb 2021 14:38:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D92CA64E86
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Feb 2021 14:38:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230001AbhBUOhz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Feb 2021 09:37:55 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36026 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229999AbhBUOhy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Feb 2021 09:37:54 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C0D0FC061574;
        Sun, 21 Feb 2021 06:37:14 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 7CFB228E5; Sun, 21 Feb 2021 09:37:12 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 7CFB228E5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1613918232;
        bh=Q0gnwv2t4NZsEC7k5ibkWa5MYZGFMGKdh3cOh4PXWJ8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=vmmiIdXpVc38B39drEy7+CfrDKlMzrhsPw0lKWzTCJbFkKCqnUlHOwIWAz/ol6J6L
         7Set20VbLn82On8qh6/QfKPeTTRywcVCfr/bvPkJ4h+wEjc9TxaB7tL2QmBzr8Uv1e
         4QvPwPbN4B4DdfXdzAJark17xbQQM9DegYBcAlU8=
Date:   Sun, 21 Feb 2021 09:37:12 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Anton Ivanov <anton.ivanov@cambridgegreys.com>
Cc:     Salvatore Bonaccorso <carnil@debian.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "940821@bugs.debian.org" <940821@bugs.debian.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Subject: Re: NFS Caching broken in 4.19.37
Message-ID: <20210221143712.GA15975@fieldses.org>
References: <5022bdc4-9f3e-9756-cbca-ada37f88ecc7@cambridgegreys.com>
 <YDFrN0rZAJBbouly@eldamar.lan>
 <af5cebbd-74c9-9345-9fe8-253fb96033f6@cambridgegreys.com>
 <BEBA9809-373A-4172-B4AD-E19D82E56DB1@oracle.com>
 <YDIkH6yVgLoALT6x@eldamar.lan>
 <9305dc03-5557-5e18-e5c9-aaf886a03fff@cambridgegreys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9305dc03-5557-5e18-e5c9-aaf886a03fff@cambridgegreys.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Feb 21, 2021 at 11:38:51AM +0000, Anton Ivanov wrote:
> On 21/02/2021 09:13, Salvatore Bonaccorso wrote:
> >On Sat, Feb 20, 2021 at 08:16:26PM +0000, Chuck Lever wrote:
> >>Confirming you are varying client-side kernels. Should the Linux
> >>NFS client maintainers be Cc'd?
> >
> >Ok, agreed. Let's add them as well. NFS client maintainers any ideas
> >on how to trackle this?
> 
> This is not observed with Debian backports 5.10 package
> 
> uname -a
> Linux madding 5.10.0-0.bpo.3-amd64 #1 SMP Debian 5.10.13-1~bpo10+1
> (2021-02-11) x86_64 GNU/Linux

I'm still unclear: when you say you tested a certain kernel: are you
varying the client-side kernel version, or the server side, or both at
once?

--b.

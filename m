Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.viabit.com ([65.246.80.16]:43096 "EHLO mail2.viabit.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751874AbdHASrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Aug 2017 14:47:43 -0400
Received: from [172.17.29.3] (vpn1.metro-data.com [65.213.236.242])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.viabit.com (Postfix) with ESMTPSA id 3xMQL65Ll6z4KSw
        for <linux-nfs@vger.kernel.org>; Tue,  1 Aug 2017 14:47:42 -0400 (EDT)
Subject: Re: [PATCH 1/1] autotools: install rpcbind to --sbindir.
To: linux-nfs@vger.kernel.org
References: <20170728135253.24542-1-michael@orlitzky.com>
 <20170728135253.24542-2-michael@orlitzky.com>
 <ab9fa53d-8301-f6e8-50d5-0ccddd2dccb6@RedHat.com>
 <87efsvvp40.fsf@notabene.neil.brown.name>
 <67dfec42-4d08-2aae-f290-70c05d20d86c@RedHat.com>
From: Michael Orlitzky <michael@orlitzky.com>
Message-ID: <40bb5c2a-e441-0575-490f-97a48966e930@orlitzky.com>
Date: Tue, 1 Aug 2017 14:47:41 -0400
MIME-Version: 1.0
In-Reply-To: <67dfec42-4d08-2aae-f290-70c05d20d86c@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/01/2017 11:27 AM, Steve Dickson wrote:
> 
> It turns out commit 5739ac634 (Fix path for rpcbind in rpcbind.service)
> move the rpcbind from sbindir to bindir and now this patch is
> moving it back?? There is definitely some confusion here!
> 

Before my patch, rpcbind was installed to bindir, so having @_sbindir@
in the systemd service file back then was wrong. After my patch, rpcbind
is actually installed to the sbindir, so that's the right thing to have
in the service file.

The original confusion may have been caused by what Neil said that they
do on SUSE, which is set

  ./configure --bindir=/sbin

We're actually doing the same thing on Gentoo, and my motivation for
this patch is so that we can stop: doing that puts rpcinfo in /sbin,
and users can't see it in their paths.

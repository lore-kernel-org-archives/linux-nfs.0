Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965010Ab3CZPWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 11:22:31 -0400
Message-ID: <5151BD35.80204@RedHat.com>
Date: Tue, 26 Mar 2013 11:22:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: libtirpc-devel@lists.sourceforge.net,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Allow building libtirpc directly against GSSAPI
References: <1364308888.2660.119.camel@willson.li.ssimo.org>
In-Reply-To: <1364308888.2660.119.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 26/03/13 10:41, Simo Sorce wrote:
> Libgssglue is not really useful anymore, it is a sort of middleman that
> wraps the actual GSSAPI that is already pluggable/extensible via shared
> modules.
> 
> In particular libgssglue interferes with the workings of gss-proxy in my
> case.
> 
> The attached patch makes building against libgssglue optional and
> defaults to not build against libgssglue and instead builds directly
> against the native GSSAPI.
> 
> ./configure --enable-gss
> will now build against GSSAPI
> 
> ./configure --enable-gss --with-gssglue
> will keep building against libgssglue in case someone still needs it for
> whatever reason.
> 
> Simo.
> 
Committed....

steved.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:59475 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab3C0Onp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 10:43:45 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1UKraA-00055u-FU
	for linux-nfs@vger.kernel.org; Wed, 27 Mar 2013 15:44:06 +0100
Received: from 60-241-78-133.static.tpgi.com.au ([60.241.78.133])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 15:44:06 +0100
Received: from oakad by 60-241-78-133.static.tpgi.com.au with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 15:44:06 +0100
To: linux-nfs@vger.kernel.org
From: Alex Dubov <oakad@yahoo.com>
Subject: Re: Allow building nfs-utils directly against GSSAPI
Date: Wed, 27 Mar 2013 14:43:27 +0000 (UTC)
Message-ID: <loom.20130327T154155-192@post.gmane.org>
References: <1364317202.2660.132.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce <simo@...> writes:

> 
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

I have tried your patch with my Heimdal setup and it would not build properly
with it.

I can augment my patch to make use of your changes. Would you be willing to
consider it?



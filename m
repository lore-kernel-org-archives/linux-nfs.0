From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/4] NLM: Introduce completion function to match
	nlmclnt_init
Date: Thu, 03 Jan 2008 16:54:08 -0500
Message-ID: <1199397248.1913.15.camel@heimdal.trondhjem.org>
References: <20071220200405.3358.54150.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:37312 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705AbYACVyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 16:54:12 -0500
In-Reply-To: <20071220200405.3358.54150.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-20 at 15:04 -0500, Chuck Lever wrote:
> Introduce the other book-end for nlmclnt_init(). This function is invoked
> by the NFS client during unmount processing to release the nlm_host struct
> that was pinned by nlmclnt_init() during mount processing.

Does this really need to be a separate patch from the nlmclnt_init?

Furthermore, those EXPORT_SYMBOL() should really be EXPORT_SYMBOL_GPL.
We don't want to make this an official ABI.

Trond


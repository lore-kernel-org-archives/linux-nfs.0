From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/11] Replacement patches for NSM IPv6 support
Date: Fri, 12 Dec 2008 13:59:51 -0500
Message-ID: <20081212185951.GB16309@fieldses.org>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbYLLS7x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:59:53 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 11, 2008 at 05:55:36PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> Here is a set of replacement patches for NSM IPv6 support.  This series
> replaces the last 11 patches of the 27 I sent previously.  I've starred
> the ones that have have changed since last Friday.
> 
> The others are included in case they may not fit over the changed
> patches, but I don't expect them to be a problem.

Thanks, all applied to for-2.6.29:

	git://linux-nfs.org/~bfields/linux.git for-2.6.29

Could you confirm that that branch has everything you've sent me so far?

Any testing of that branch also greatly appreciated....

Looking forward to nfsd patches.  (And then are we done with ipv6?)

--b.

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] lockd: Add address family-agnostic helper for
	zeroing the port number
Date: Tue, 26 Aug 2008 15:17:50 -0400
Message-ID: <20080826191750.GH4380@fieldses.org>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164232.20488.11685.stgit@manray.1015granger.net> <20080826190319.GF4380@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60923 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753661AbYHZTSB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2008 15:18:01 -0400
In-Reply-To: <20080826190319.GF4380@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2008 at 03:03:19PM -0400, bfields wrote:
> It would be nice if not necessary just to move nfs_set_port() somewhere
> common and use that (maybe with a more generic name).
> 
> That aside, all 5 patches are OK by me.

Provisionally applied all but the first (purely client-side) patch to

	git://linux-nfs.org/~bfields/linux.git for-2.6.28

Do you have any good regression tests for nsm?

--b.

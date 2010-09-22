From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Revert "nfsd4: distinguish expired from stale stateids"
Date: Wed, 22 Sep 2010 15:39:33 -0400
Message-ID: <20100922193933.GJ26903@fieldses.org>
References: <20100518233746.GC26911@fieldses.org>
 <4C563CE5.1010101@cn.fujitsu.com>
 <20100802135036.GA12637@fieldses.org>
 <4C57DD66.1070001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365Ab0IVTlC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 15:41:02 -0400
In-Reply-To: <4C57DD66.1070001@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 03, 2010 at 05:12:06PM +0800, Bian Naimeng wrote:
>   As i see, this question is difficult to slove. Freebsd looks like nerver return 
>   the NFSERR_EXPIRED error.  And solaris more than happy to return NFSERR_EXPIRED 
>   rather than NFSERR_BAD_STATEID when the stateid is not found at server.
> 
>   I mean it's difficult to distinguish expired_stateid and bad_stateid(they are not
>   exist at server), so maybe we have not a exactly solution to solve it.
> 
>   Maybe we should choose which error we are more needed, NFSERR_EXPIRED  or NFSERR_BAD_STATEID?

Yes, that would probably be simplest.

--b.

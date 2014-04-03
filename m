Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752801AbaDCRQs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 13:16:48 -0400
Date: Thu, 3 Apr 2014 13:16:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Mark Lord <mlord@pobox.com>
Cc: Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
Message-ID: <20140403171643.GB28790@pad.redhat.com>
References: <533D8D73.1090603@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <533D8D73.1090603@pobox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2014 at 12:33:55PM -0400, Mark Lord wrote:
> This commit from linux-3.14 breaks our NFS-root clients here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6e14b46b91fee8a049b0940333ce13a820beaaa5
> 
> 
> - *p++ = htonl((u32) stat->mode);
> + *p++ = htonl((u32) (stat->mode & S_IALLUGO));
> 
> 
> Reverting the one-liner above (on the server) fixes it for us,
> as does reverting back to linux-3.13.8 on the server.
> 
> The NFS-root clients are on PowerPC (big-endian) architecture,
> running linux-3.12.16. The NFS server is on an Intel PC running linux-3.14.
> 
> ACL is completely disabled on server and client,
> and we're using NFSv2/v3.  No support for v4.
> 
> I instrumented the function to see what other bits were being cleared
> by the (stat->mode & S_IALLUGO) masking.  The results are attached.

Hm, it sounds like a bug in the client if it's depending on those high
bits.

The original behavior was in practice harmless and changing it broke
something, so I think we should definitely just revert this patch.

But the client may need fixing too.

--b.

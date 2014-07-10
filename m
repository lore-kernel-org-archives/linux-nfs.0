Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45331 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbaGJMnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:43:06 -0400
Date: Thu, 10 Jul 2014 05:43:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Message-ID: <20140710124305.GA30941@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-16-git-send-email-jlayton@primarydata.com>
 <20140710103100.GA6935@infradead.org>
 <20140710081912.4af7c35b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710081912.4af7c35b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 08:19:12AM -0400, Jeff Layton wrote:
> 
> No, the st_deny_bmap does not hold the NFS_SHARE_DENY_* bits
> themselves. It sets a bit for each NFS_SHARE_DENY_* mode that the
> stateid has used. The difference is subtle, but significant.
> 
> The rationale for that is in the comments above bmap_to_share_mode.

Oh, the dangers of the bitshift index access helper confusing the
reader.

But I think this is only really nessecary because of the odd fi_access
semantics, and if we sort that out as suggested by me earlier we can
get rid of this confusion as the access/deny checks don't really care
about the additional both bit, and once the the O_RDWR file has it's own
proper refconting there shouldn't be any need to treat it special.


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55508 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423235AbcFMTpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 15:45:45 -0400
Date: Mon, 13 Jun 2016 15:45:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/2] Sharing flex file XDR encoding between client and
 server
Message-ID: <20160613194543.GC19825@fieldses.org>
References: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 07, 2016 at 04:34:44PM -0700, Tom Haynes wrote:
> This builds on my prior change set for the flex file server.
> 
> I'm not too hot on putting this much code in a header, but
> I can't think of a cleaner way without leaking too much
> between the client and server.
> 
> Any guidance on how this is typically approached?

Looks like there's some cut-and-paste from net/sunrpc/addr.c.  Any
reason not to just use those functions and/or add any necessary new
stuff there?

--b.

> 
> Thanks,
> Tom
> 
> 
> Tom Haynes (2):
>   nfs: Encoding a netaddr is common to client and server
>   nfsd: Encode a netaddr correctly
> 
>  fs/nfs/flexfilelayout/flexfilelayout.c |  93 +-----------------------------
>  fs/nfs/flexfilelayout/flexfilelayout.h |   5 +-
>  fs/nfsd/flexfilelayout.c               |  26 +--------
>  fs/nfsd/flexfilelayoutxdr.c            |  34 +++++------
>  fs/nfsd/flexfilelayoutxdr.h            |  15 +----
>  include/linux/nfs4_ff.h                | 100 +++++++++++++++++++++++++++++++++
>  6 files changed, 120 insertions(+), 153 deletions(-)
>  create mode 100644 include/linux/nfs4_ff.h
> 
> -- 
> 2.5.5

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbaELVqI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 17:46:08 -0400
Date: Mon, 12 May 2014 17:45:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/43] nfsd4: reserve head space for krb5 integ/priv info
Message-ID: <20140512214545.GA11493@pad.redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-5-git-send-email-bfields@redhat.com>
 <20140512053727.GE29134@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512053727.GE29134@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 10:37:27PM -0700, Christoph Hellwig wrote:
> On Sun, May 11, 2014 at 04:52:09PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Currently if the nfs-level part of a reply would be too large, we'll
> > return an error to the client.  But if the nfs-level part fits and
> > leaves no room for krb5p or krb5i stuff, then we just drop the request
> > entirely.
> > 
> > That's no good.  Instead, reserve some slack space at the end of the
> > buffer and make sure we fail outright if we'd come close.
> > 
> > The slack space here is a massive overstimate of what's required, we
> > should probably try for a tighter limit at some point.
> 
> Don't we know the rpc auth scheme at this point and can at least
> avoid it for non-krb setups?

Yes.  At the end of this series we have RPC_MAX_AUTH_SIZE scattered
around in a few different places.  Rather than have each place have some
flavor-specific logic I think I'd like the auth code to set an
rq_auth_slack field in the struct svc_rqst for code like this to use.

--b.

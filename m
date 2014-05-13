Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50989 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbaEMFFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 May 2014 01:05:53 -0400
Date: Mon, 12 May 2014 22:05:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/43] nfsd4: reserve head space for krb5 integ/priv info
Message-ID: <20140513050553.GA5056@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-5-git-send-email-bfields@redhat.com>
 <20140512053727.GE29134@infradead.org>
 <20140512214545.GA11493@pad.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512214545.GA11493@pad.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2014 at 05:45:45PM -0400, J. Bruce Fields wrote:
> Yes.  At the end of this series we have RPC_MAX_AUTH_SIZE scattered
> around in a few different places.  Rather than have each place have some
> flavor-specific logic I think I'd like the auth code to set an
> rq_auth_slack field in the struct svc_rqst for code like this to use.

That sounds pretty reasonable to me.

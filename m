Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44658 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbbG3Qem (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 12:34:42 -0400
Date: Thu, 30 Jul 2015 09:34:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do nfs4_check_fh in nfs4_check_file instead of
 nfs4_check_olstateid
Message-ID: <20150730163441.GA5115@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438264341-18048-2-git-send-email-jeff.layton@primarydata.com>
 <20150730155135.GB1073@infradead.org>
 <20150730122048.3ec42317@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150730122048.3ec42317@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 12:20:48PM -0400, Jeff Layton wrote:
> So, this just adds this check to delegation stateids (which is
> necessary I think). That is mentioned in the changelog though. Do you
> think it needs more elaboration or is that sufficient?

No, I'm just thick today.  The patch looks fine as-is!

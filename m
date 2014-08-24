Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58751 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbaHXQLe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 12:11:34 -0400
Date: Sun, 24 Aug 2014 09:11:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/10] locks: move i_lock acquisition into
 generic_*_lease handlers
Message-ID: <20140824161134.GJ15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-9-git-send-email-jlayton@primarydata.com>
 <20140824160634.GG15908@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140824160634.GG15908@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 24, 2014 at 09:06:34AM -0700, Christoph Hellwig wrote:
> We really should split a lm_release from lm_change, the way it is
> used is highly confusing.  In addition I think a lot of code
> currently in lease_modify should move here instead, e.g. something like:

At this point the old lm_change actually becomes superflous if we
simply disallow changes for delegation.


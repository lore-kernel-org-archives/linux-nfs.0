Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60544 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933927AbaGPO33 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 10:29:29 -0400
Date: Wed, 16 Jul 2014 07:29:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] nfsd: Ensure stateids remain unique until they are
 freed
Message-ID: <20140716142928.GA9671@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
 <1405420669-4030-3-git-send-email-jlayton@primarydata.com>
 <20140715171547.GA5269@infradead.org>
 <20140716081738.05ce6d92@tlielax.poochiereds.net>
 <20140716134945.GA11961@infradead.org>
 <20140716102824.27eeb209@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140716102824.27eeb209@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 10:28:24AM -0400, Jeff Layton wrote:
> Unfortunately, that creates a pile of merge conflicts in the later
> patches. I'll just go ahead and change that and resend all of the
> delegation patches that Bruce hasn't merged yet. Stay tuned...

Just keep it as is if it's too painful.  This isn't really something
that matters too much in the end.


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:44509 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886AbbC3Qoz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 12:44:55 -0400
Date: Mon, 30 Mar 2015 18:44:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150330164453.GA2927@lst.de>
References: <20150303221033.GB19439@fieldses.org> <20150327104135.GA15651@lst.de> <20150327105029.615354f3@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150327105029.615354f3@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:50:29AM -0400, Jeff Layton wrote:
> 
> Taking a quick look, the ->done routines look a little suspicious to me
> anyway. AFAICT, the pc_decode routines for the callbacks always return
> a Linux errno, not a nfsstat4, and that's what should end up in
> tk_status.

Only for errors where nfs_cb_stat_to_errno knowns how to translate
them, which aren't those we're worried about here.

However this partial translation looks really suspiios to me, I'd
really wish we could have a linux tk_status, and then an NFS-specific
way to transfer the errno.  I'd also love to have a new __bitwise
type so that we can ensure NFS errnos are used properly.

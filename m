Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:53912 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbbLHPV0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Dec 2015 10:21:26 -0500
Date: Tue, 8 Dec 2015 16:21:23 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>, Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [RFC PATCH 2/2] nfsd: give up on CB_LAYOUTRECALLs after two
	lease periods
Message-ID: <20151208152123.GB4035@lst.de>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com> <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 08, 2015 at 07:23:48AM -0500, Jeff Layton wrote:
> Have the CB_LAYOUTRECALL code treat NFS4_OK and NFS4ERR_DELAY returns
> equivalently. Change the code to periodically resend CB_LAYOUTRECALLS
> until the ls_layouts list is empty or the client returns a different
> error code.
> 
> If we go for two lease periods without the list being emptied or the
> client sending a hard error, then we give up and clean out the list
> anyway.

This looks reasonable to me, but I'll need to actually test it
before giving an ACK.

Btw, it seems like the delegation and layoutrecall code would benefit
from some more code sharing for timeouts.  For example delegation
returns currently don't support NFS4ERR_DELAY at all.

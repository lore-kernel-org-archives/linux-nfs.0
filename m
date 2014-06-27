Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49983 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbaF0QWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2014 12:22:35 -0400
Date: Fri, 27 Jun 2014 12:22:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140627162234.GA15610@fieldses.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:11:40PM -0400, Jeff Layton wrote:
> I'd still like to see this merged for v3.17, so it would be ideal to
> merge this into linux-next soon if possible. Bruce, please let me know
> what you think the prospects are.

I'm currently using the "for-3.17" branch at

	git://linux-nfs.org/~bfields/linux.git

to hold any changes that I think are well and truly committed (so that
should be rebased never or only very rarely) and "nfsd-next" for things
that have been posted but may still be waiting for review (including
these), and may still be revised or dropped.

I should probably come up with some more sensible scheme....

I already had the first six patches.  I assumed without checking really
carefully that you hadn't revised the versions you sent me, let me know
if otherwise.

--b.

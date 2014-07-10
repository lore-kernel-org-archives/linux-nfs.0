Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44012 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaGJIDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 04:03:38 -0400
Date: Thu, 10 Jul 2014 01:03:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 012/100] nfsd: remove nfs4_file_put_fd
Message-ID: <20140710080336.GB6226@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-13-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-13-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 02:03:00PM -0400, Jeff Layton wrote:
> ...and replace it with a simple swap call.

While trying to understand this code I'm failing to grasp the point
of the fi_access counters.  Why can't we simply grab a reference to
file everytime we increment fi_access, and simply drop it evertime we
decrement it?

Note that the comment explaining fi_access also seems wrong, as it
suggest contributing 0-4 to the counts, but at best we increment each
one by 1 in a single operation.

Also as you touch this area big time:  I think fi_fds should be renamed
to fi_fils or similar as we point to file structures and not fds.

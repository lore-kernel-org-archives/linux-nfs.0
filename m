From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/2] nfsd: open a file descriptor for fsync in nfs4
 recovery
Date: Mon, 22 Mar 2010 16:39:41 +0000
Message-ID: <20100322163941.GF30031@ZenIV.linux.org.uk>
References: <20100322163214.GA1307@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59124 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048Ab0CVQjm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Mar 2010 12:39:42 -0400
In-Reply-To: <20100322163214.GA1307@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 22, 2010 at 05:32:14PM +0100, Christoph Hellwig wrote:
> Instead of just looking up a path use do_filp_open to get us a file
> structure for the nfs4 recovery directory.  This allows us to get
> rid of the last non-standard vfs_fsync caller with a NULL file
> pointer.

Applied with cosmetical change (use of local variables).  The second patch
applied as-is.

I'll start moving stuff from local queue to for-next later today.

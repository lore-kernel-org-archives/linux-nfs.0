From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 15/17] nfs: Remove reference to generic_osync_inode
 from a comment
Date: Fri, 21 Aug 2009 13:52:00 -0400
Message-ID: <1250877120.27154.11.camel@heimdal.trondhjem.org>
References: <1250875447-15622-1-git-send-email-jack@suse.cz>
	 <1250875447-15622-16-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: LKML <linux-kernel@vger.kernel.org>, hch@lst.de,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39896 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695AbZHURwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 13:52:04 -0400
In-Reply-To: <1250875447-15622-16-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 19:24 +0200, Jan Kara wrote:
> generic_file_direct_write() no longer calls generic_osync_inode() so remove the
> comment.

Thanks. I've applied it to the nfs-for-2.6.32 branch.

Cheers
  Trond


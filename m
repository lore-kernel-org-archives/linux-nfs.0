Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46890 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241AbbK3W4a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2015 17:56:30 -0500
Date: Mon, 30 Nov 2015 17:56:29 -0500
To: Christoph Hellwig <hch@lst.de>
Cc: viro@zeniv.linux.org.uk, tao.peng@primarydata.com,
        jeff.layton@primarydata.com, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: vfs: move btrfs clone ioctls to common code
Message-ID: <20151130225629.GC31564@fieldses.org>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1448563859-21922-1-git-send-email-hch@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 26, 2015 at 07:50:54PM +0100, Christoph Hellwig wrote:
> This patch set moves the existing btrfs clone ioctls that other file
> system have started to implement to common code, and allows the NFS
> server to export this functionality to remote systems.
> 
> This work is based originally on my NFS CLONE prototype, which reused
> code from Anna Schumaker's NFS COPY prototype, as well as various
> updates from Peng Tao to this code.

Looks good to me.  (In particular: ACK to the locks.c and nfsd patches.
But, disclaimer, I haven't tried to test clone.)

--b.

> 
> The patches are also available as a git branch and on gitweb:
> 
> 	git://git.infradead.org/users/hch/pnfs.git clone-for-viro
> 	http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone-for-viro
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

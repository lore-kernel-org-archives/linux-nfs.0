Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:53822 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779AbbLHOy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Dec 2015 09:54:56 -0500
Date: Tue, 8 Dec 2015 15:54:53 +0100
From: Christoph Hellwig <hch@lst.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, tao.peng@primarydata.com,
        jeff.layton@primarydata.com, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 1/4] locks: new locks_mandatory_area calling convention
Message-ID: <20151208145453.GA3621@lst.de>
References: <1449143992-7415-1-git-send-email-hch@lst.de> <1449143992-7415-2-git-send-email-hch@lst.de> <20151208040504.GA2791@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151208040504.GA2791@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 08, 2015 at 04:05:04AM +0000, Al Viro wrote:
> Where the hell would truncate(2) get struct file, anyway?  IOW, the inode
> argument is _not_ pointless; re-added.

Oh, right.  Interestingly is seems like xfstests has no coverage of this
code path at all.

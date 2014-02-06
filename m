Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49264 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756793AbaBFREP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Feb 2014 12:04:15 -0500
Date: Thu, 6 Feb 2014 12:03:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>, Harshula <hjayasur@redhat.com>,
        hfuchi@redhat.com, Trond Myklebust <trondmy@gmail.com>
Subject: Re: [PATCH] dcache: make d_splice_alias use d_materialise_unique
Message-ID: <20140206170348.GD14575@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
 <20140117153917.GA26636@fieldses.org>
 <20140117210343.GD26636@fieldses.org>
 <20140117212655.GE26636@fieldses.org>
 <20140123212700.GA30466@fieldses.org>
 <20140131184258.GN10323@ZenIV.linux.org.uk>
 <20140131194758.GA24618@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140131194758.GA24618@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 31, 2014 at 02:47:58PM -0500, J. Bruce Fields wrote:
> (Then one remaining thing I don't understand is how to make that fixing
> up reliable.  Or is there some reason nobody hits the _EBUSY case of
> __d_unalias?)

In fact, a reproducer found thanks to Hideshi Yamaoka:

On server:

	while true; do
		mv /exports/DIR /exports/TO/DIR
		mv /exports/TO/DIR /exports/DIR
	done

On client:

	mount -olookupcache=pos /mnt

	while true; do
		ls /mnt/TO;
	done

Also on client:

	while true; do
		strace -e open cat /mnt/DIR/test.txt 2>&1 | grep EBUSY
	done

Once all three of those loops are running I hit

	open("/mnt/DIR/test.txt", O_RDONLY)	= -1 EBUSY

very quickly.

The "lookupcache=pos" isn't really necessary but makes the reproducer
more reliable.

(Originally this was seen on a single client: the client itself was
doing the renames but also continually killing the second mv.  I suspect
that means the client sends the RENAME but then fails to update its
dcache, the result being again that the client's dcache is out of sync
with the server's tree and hence lookup is stuck trying to grab a dentry
from another directory.)

Is there some solution short of making ->lookup callers drop the i_mutex
and retry???

--b.

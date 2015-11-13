Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59924 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbKMI62 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:58:28 -0500
Date: Fri, 13 Nov 2015 00:58:22 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org,
        Steve French <steve.french@primarydata.com>
Subject: Re: [PATCH 1/9] vfs: add COPY_FILE_CLONE_ONLY flag
Message-ID: <20151113085822.GA2272@infradead.org>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
 <1445728636-10109-2-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445728636-10109-2-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 25, 2015 at 07:17:08AM +0800, Peng Tao wrote:
> To tell file system not to return partial success in the
> .copy_file_range method. This is useful to implement the
> clone (or reflink) functionality.

The return value is only part of it, the other part is to
make it atomic.  Thus I don't think overloading copy_file_range
is a good idea - we should have a seaprate .clone_file_range that
is called by the btrfs ioctls moved to the core, and have
vfs_copy_file_range use .clone_file_range if that exists, and
if none of the potentially conflicting future flags like
COPY_FALLOC are present.

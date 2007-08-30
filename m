From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/3] VFS: make notify_change pass ATTR_KILL_S*ID to setattr operations
Date: Thu, 30 Aug 2007 17:33:56 +0100
Message-ID: <20070830163356.GA12512@infradead.org>
References: <200708301506.l7UF6c63002133@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200708301506.l7UF6c63002133@dantu.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Aug 30, 2007 at 11:06:38AM -0400, Jeff Layton wrote:
> Make notify_change not clear the ATTR_KILL_S*ID bits in the ia_vaid that
> gets passed to the setattr inode operation. This allows the filesystems
> to reinterpret whether this mode change is simply intended to clear the
> setuid/setgid bits.
> 
> This means that notify_change should never be called with both ATTR_MODE
> and either of the ATTR_KILL_S*ID bits set, since the filesystem would
> have no way to know what part of the mode change was intentional. If
> it is called this way, consider it a BUG().

This one looks fine to, but you'll probably need an additional patch
to ecryptfs so it clears ATTR_MODE before calling notify_change for
the lower inode.


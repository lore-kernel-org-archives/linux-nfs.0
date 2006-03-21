From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [GIT] NFS client update for 2.6.16
Date: Tue, 21 Mar 2006 17:46:34 +0000
Message-ID: <20060321174634.GA15827@infradead.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964813AbWCURql@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1142961077.7987.14.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> commit 47989d7454398827500d0e73766270986a3b488f
> Author: Chuck Lever <cel@netapp.com>
> Date:   Mon Mar 20 13:44:32 2006 -0500
> 
>     NFS: remove support for multi-segment iovs in the direct write path
>     
>     Eliminate the persistent use of automatic storage in all parts of the
>     NFS client's direct write path to pave the way for introducing support
>     for aio against files opened with the O_DIRECT flag.

NACK.  We have patches pending that consolidate ->aio_read/write and
->read/writev into one operation.  this change is completely counterproductive
towards that goal which has been discussed on -fsdevel for a while.

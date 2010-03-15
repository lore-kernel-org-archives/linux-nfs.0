From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] vfs: pass struct file to do_truncate on O_TRUNC opens
Date: Mon, 15 Mar 2010 22:50:37 +0000
Message-ID: <20100315225037.GX30031@ZenIV.linux.org.uk>
References: <1268689152-19168-1-git-send-email-jlayton@redhat.com>
 <1268692288.3040.2.camel@localhost.localdomain>
 <20100315184702.35c4d140@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100315184702.35c4d140@tlielax.poochiereds.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 15, 2010 at 06:47:02PM -0400, Jeff Layton wrote:

> Yeah that would be cleaner on the wire for the create case. It's not
> clear to me how to implement that though. There doesn't appear to be
> a straightforward way to tell the VFS to skip the truncate.

The plan is to turn most of the guts of do_last() into fs method...

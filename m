From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] vfs: pass struct file to do_truncate on O_TRUNC opens
Date: Mon, 15 Mar 2010 19:03:33 -0400
Message-ID: <20100315190333.195a327a@tlielax.poochiereds.net>
References: <1268689152-19168-1-git-send-email-jlayton@redhat.com>
	<1268692288.3040.2.camel@localhost.localdomain>
	<20100315184702.35c4d140@tlielax.poochiereds.net>
	<20100315225037.GX30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24615 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937092Ab0COXDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 19:03:42 -0400
In-Reply-To: <20100315225037.GX30031@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 15 Mar 2010 22:50:37 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Mar 15, 2010 at 06:47:02PM -0400, Jeff Layton wrote:
> 
> > Yeah that would be cleaner on the wire for the create case. It's not
> > clear to me how to implement that though. There doesn't appear to be
> > a straightforward way to tell the VFS to skip the truncate.
> 
> The plan is to turn most of the guts of do_last() into fs method...

Thanks Al, that makes sense.

Does the patch I've proposed look reasonable in the interim?
-- 
Jeff Layton <jlayton@redhat.com>

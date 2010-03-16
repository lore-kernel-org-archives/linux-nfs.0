Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938126Ab0CPRr1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 13:47:27 -0400
Date: Tue, 16 Mar 2010 13:47:19 -0400
From: Valerie Aurora <vaurora@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] vfs: pass struct file to do_truncate on O_TRUNC opens
Message-ID: <20100316174719.GA24819@shell>
References: <1268689152-19168-1-git-send-email-jlayton@redhat.com> <1268692288.3040.2.camel@localhost.localdomain> <20100315184702.35c4d140@tlielax.poochiereds.net> <20100315225037.GX30031@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100315225037.GX30031@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 15, 2010 at 10:50:37PM +0000, Al Viro wrote:
> On Mon, Mar 15, 2010 at 06:47:02PM -0400, Jeff Layton wrote:
> 
> > Yeah that would be cleaner on the wire for the create case. It's not
> > clear to me how to implement that though. There doesn't appear to be
> > a straightforward way to tell the VFS to skip the truncate.
> 
> The plan is to turn most of the guts of do_last() into fs method...

For union mounts, we will want to skip the truncate too (or else
insinuate ourselves into do_truncate() - less attractive).  This is
because we want to only copy up the bytes that are not being
truncated, instead of copying up the file contents and then throwing
them away.

What's the timing on the do_last() change?  Do you know what branch it
will be in?

Thanks,

-VAL

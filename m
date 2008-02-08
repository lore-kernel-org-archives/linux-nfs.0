From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 08 Feb 2008 10:13:16 -0500
Message-ID: <1202483596.8914.13.camel@heimdal.trondhjem.org>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:34713 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759014AbYBHPNU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 10:13:20 -0500
In-Reply-To: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-02-08 at 10:04 -0500, Jeff Layton wrote:
> Recently, I ran across a server-side bug that caused the server to send
> truncated READDIR replies. The server would send a valid RPC response to
> a READDIR call, but the contents of it were basically missing
> (everything after the status).
> 
> The server problem had long been patched in mainline kernels, but the
> interesting bit was that clients didn't return an error in this
> situation. The XDR decoders for readdir calls are supposed to check the
> validity of the response, but in this situation it just fudges the
> contents of the pagecache to make it look like a completely empty
> directory.
> 
> Shouldn't the client return an error in this situation? The response
> obviously isn't valid so it seems like it shouldn't pretend that it is.
> If so, would something like the following patch make sense?

It is quite valid (though silly!) for a server to return a READDIR reply
with no entries. AFAICR there were servers that actually did this at one
point (though I shall refrain from naming and shaming).

So whereas I agree that it might be correct to flag a READDIR reply that
contains no entries due to XDR encoding bugs, I'm not sure that we
should be flagging errors in the case where the XDR is correct.

Cheers
  Trond


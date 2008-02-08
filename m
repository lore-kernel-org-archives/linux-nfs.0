From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 8 Feb 2008 10:56:59 -0500
Message-ID: <20080208105659.3bfb8a6b@tleilax.poochiereds.net>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	<1202483596.8914.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758645AbYBHP5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 10:57:20 -0500
In-Reply-To: <1202483596.8914.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Feb 2008 10:13:16 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Fri, 2008-02-08 at 10:04 -0500, Jeff Layton wrote:
> > Recently, I ran across a server-side bug that caused the server to send
> > truncated READDIR replies. The server would send a valid RPC response to
> > a READDIR call, but the contents of it were basically missing
> > (everything after the status).
> > 
> > The server problem had long been patched in mainline kernels, but the
> > interesting bit was that clients didn't return an error in this
> > situation. The XDR decoders for readdir calls are supposed to check the
> > validity of the response, but in this situation it just fudges the
> > contents of the pagecache to make it look like a completely empty
> > directory.
> > 
> > Shouldn't the client return an error in this situation? The response
> > obviously isn't valid so it seems like it shouldn't pretend that it is.
> > If so, would something like the following patch make sense?
> 
> It is quite valid (though silly!) for a server to return a READDIR reply
> with no entries. AFAICR there were servers that actually did this at one
> point (though I shall refrain from naming and shaming).
> 
> So whereas I agree that it might be correct to flag a READDIR reply that
> contains no entries due to XDR encoding bugs, I'm not sure that we
> should be flagging errors in the case where the XDR is correct.
> 

Ok. In this case there was nothing in the packet after the status code,
so I don't think the XDR was correct. There was no "value follows" entry
and no EOF flag. Wireshark flagged it as a malformed packet.

If I read the spec right, a valid but empty response from the server
should look like:

status code == 0 (ok)
value follows == 0
EOF == 1 (or maybe 0?)

If we get a packet that looks like that and has EOF set to 1, then we
don't "goto short_pkt". That case would be unaffected by this patch.

If it looks like the above, but EOF is 0, then we *do* "goto
short_pkt", and that case would be affected by this. But in that case
we currently reset EOF to 1. The client won't retry the request. I'm
not sure that's what we want to do either...

PS: I have a binary capture if my description isn't clear...

-- 
Jeff Layton <jlayton@redhat.com>

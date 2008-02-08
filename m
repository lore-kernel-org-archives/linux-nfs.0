From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 8 Feb 2008 11:18:05 -0500
Message-ID: <20080208111805.390c4b1a@tleilax.poochiereds.net>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	<1202483596.8914.13.camel@heimdal.trondhjem.org>
	<47AC77C6.80503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754264AbYBHQSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 11:18:33 -0500
In-Reply-To: <47AC77C6.80503@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Feb 2008 10:39:50 -0500
Peter Staubach <staubach@redhat.com> wrote:

> Trond Myklebust wrote:
> > On Fri, 2008-02-08 at 10:04 -0500, Jeff Layton wrote:
> >   
> >> Recently, I ran across a server-side bug that caused the server to send
> >> truncated READDIR replies. The server would send a valid RPC response to
> >> a READDIR call, but the contents of it were basically missing
> >> (everything after the status).
> >>
> >> The server problem had long been patched in mainline kernels, but the
> >> interesting bit was that clients didn't return an error in this
> >> situation. The XDR decoders for readdir calls are supposed to check the
> >> validity of the response, but in this situation it just fudges the
> >> contents of the pagecache to make it look like a completely empty
> >> directory.
> >>
> >> Shouldn't the client return an error in this situation? The response
> >> obviously isn't valid so it seems like it shouldn't pretend that it is.
> >> If so, would something like the following patch make sense?
> >>     
> >
> > It is quite valid (though silly!) for a server to return a READDIR reply
> > with no entries. AFAICR there were servers that actually did this at one
> > point (though I shall refrain from naming and shaming).
> >
> > So whereas I agree that it might be correct to flag a READDIR reply that
> > contains no entries due to XDR encoding bugs, I'm not sure that we
> > should be flagging errors in the case where the XDR is correct.
> 
> In this case, I believe that the response was malformed.  Pretty
> much everything after the status was missing, including the EOF
> indicator.  I would agree that it would be silly to return a
> response with no error indicated, no entries, and the eof
> indication set to false.
> 
> This really boils down to how do we handle malformed responses?
> Is there a general policy to retransmit the request?  This would
> seem to be the right thing because a malformed response would
> result from many things including the TCP connection getting
> dropped in the middle of receiving the response from a timeout
> and other things.  However, in this situation, retransmitting
> the request would just have resulted in the same, broken response
> from the server.  This was due to a server bug, which has since
> been fixed, but exists still out in nature.
> 

In the above case, wouldn't the malformed response also have meant that
the RPC layer was malformed (or lower layers even)? In that case, the
kernel would probably retransmit the request anyway, wouldn't it?

This case is odd in that the UDP/RPC layers were consistent length-wise.
The NFS payload was just incomplete...

-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43635 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761425Ab3JPShJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 14:37:09 -0400
Date: Wed, 16 Oct 2013 14:37:07 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc: change BUG to WARN in gss_encode_v1_msg
Message-ID: <20131016183707.GB19067@fieldses.org>
References: <1380721695-14755-1-git-send-email-bfields@redhat.com>
 <1381947473.17178.2.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381947473.17178.2.camel@leira.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 06:17:54PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-10-02 at 09:48 -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Failure of this assertion would indeed be serious, but as we've seen a
> > BUG() in a worker thread (this can run from rpciod context) can screw up
> > the system so badly that the oops doesn't even get to the logs; better
> > to WARN() and soldier on.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/auth_gss.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 0846566..254a9f0 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -454,7 +454,7 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
> >  	gss_msg->msg.len += len;
> >  
> >  	gss_msg->msg.data = gss_msg->databuf;
> > -	BUG_ON(gss_msg->msg.len > UPCALL_BUF_LEN);
> > +	WARN_ON_ONCE(gss_msg->msg.len > UPCALL_BUF_LEN);
> >  }
> >  
> >  static struct gss_upcall_msg *
> 
> Umm.... Why aren't we using scnprintf() in order to prevent string
> buffer overflows before they happen?

Yeah, this should really be caught earlier.

And we want to actually fail, not give gssd a truncated request.

--b.

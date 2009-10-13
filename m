Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760812AbZJMSDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 14:03:42 -0400
Date: Tue, 13 Oct 2009 14:03:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Kevin Coffman <kwc@citi.umich.edu>, raini@rainiday.com,
        linux-nfs@vger.kernel.org
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Message-ID: <20091013140306.476b20fd@tlielax.poochiereds.net>
In-Reply-To: <1255456293.3711.103.camel@heimdal.trondhjem.org>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	<20091009121602.5ec86dfb@tlielax.poochiereds.net>
	<1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	<20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	<ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	<20091013114441.2882c8b9@tlielax.poochiereds.net>
	<4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
	<1255452985.3711.85.camel@heimdal.trondhjem.org>
	<20091013132701.72927b4d@tlielax.poochiereds.net>
	<1255456293.3711.103.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 13 Oct 2009 13:51:33 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2009-10-13 at 13:27 -0400, Jeff Layton wrote:
> > Correct...and gssd actually does check the validity of the cache. If
> > TGT has expired or it's not valid for some other reason, then it skips
> > it and moves on.
> > 
> > The problem comes when you have more than one valid credcache. In that
> > case it picks the one with the latest mtime. It seems that it should
> > instead pick the one with the latest TGT expiration time.
> 
> So why do you think that is a problem? The result should be that
> rpc.gssd always ends up with a valid credential as long as there is at
> least one with a valid TGT.
> IOW: Who cares if the GSS session isn't going to last as long, as long
> as the RPC client can always instantiate a new one.
> 

Hrm...good point. I suppose that as long as gssd can pick a new
credcache if the context expires then this patch is superfluous. Wasn't
that support only added fairly recently (around a year ago?)? If so, it
may just be that raini isn't using a recent enough nfs-utils...

-- 
Jeff Layton <jlayton@redhat.com>

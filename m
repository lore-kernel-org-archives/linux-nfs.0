Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab3KCLBv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Nov 2013 06:01:51 -0500
Date: Sun, 3 Nov 2013 06:01:45 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>
Subject: Re: [PATCH] nfs: set security label when revalidating inode
Message-ID: <20131103060145.73443e75@tlielax.poochiereds.net>
In-Reply-To: <20131103051438.3a4db316@tlielax.poochiereds.net>
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
	<C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
	<20131103051438.3a4db316@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 3 Nov 2013 05:14:38 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Sun, 3 Nov 2013 02:23:29 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > 
> > On Nov 2, 2013, at 6:57, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > Currently, we fetch the security label when revalidating an inode's
> > > attributes, but don't apply it. This is in contrast to the readdir()
> > > codepath where we do apply label changes.
> > 
> > OK. Why should we not just throw out the code that fetches the security label here?
> > 
> > IOW: what is the caching model that is being implemented in this patch; is it just “fetch label at random intervals” or is there real method to the madness?
> > 
> > Trond
> 
> I think that we should apply the new security label as soon as we
> realize that it has changed. Why should we treat the security label
> differently from any other inode attribute (e.g. ownership or mode)?
> 

Ok, I think I understand what you're getting at now that I've had a cup
of coffee ;)

I guess you're pointing out a problem with the overall model, given that
the current implementation doesn't send anything in the RPC to denote
the security context of the client's task?

It's a fair point, and not one I have a great answer for. I think that
you're correct that for the most part that they won't change. But when
they do, what's to be gained by ignoring that?

They'll never be permanent anyway...as soon as the inode gets tossed
out of the cache or the client reboots then you'll see the change on
the next access of it.

-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56868 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751436AbdI0VGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Sep 2017 17:06:51 -0400
Date: Wed, 27 Sep 2017 17:06:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Meng Xu <mengxu.gatech@gmail.com>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, meng.xu@gatech.edu,
        sanidhya@gatech.edu, taesoo@gatech.edu
Subject: Re: [PATCH] nfsd4: ensure cm_xid does not change across userspace
 fetches
Message-ID: <20170927210650.GA16674@fieldses.org>
References: <1506272380-17769-1-git-send-email-mengxu.gatech@gmail.com>
 <20170926215216.GA30989@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170926215216.GA30989@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 26, 2017 at 05:52:16PM -0400, J. Bruce Fields wrote:
> On Sun, Sep 24, 2017 at 12:59:40PM -0400, Meng Xu wrote:
> > cld_pipe_downcall() has two fetches from an overapped userspace memory.
> > The first fetch copy_from_user(&xid, &cmsg->cm_xid, sizeof(xid)) get
> > the xid and use xid to lookup the parent struct cld_upcall *cup.
> > The second fetch copy_from_user(&cup->cu_msg, src, mlen) place the whole
> > message into &cup->cu_msg.
> > 
> > Since the userspace thread has full control over this &cmsg->cm_xid,
> > it can race condition to change the cm_xid value across the two fetches,
> > (say, change from 1 to 2), therefore, de-listing the cup with
> > cu_msg.cm_xid == 1 but later put cu_msg.cm_xid = 2.
> > 
> > Whether this double-fetch situation is a security critical bug depends
> > on how cup->cu_msg is used later. However, given that it is hard to
> > enumerate all the possible use cases, a safer way might be to ensure
> > that the xid does not change across the fetches, which is what this
> > patch is for.
> 
> Alternatively, couldn't we copy the whole message just once at the
> start?  It doesn't look like there very large, so there's room for it on
> the stack, if that's the problem.

Well, I'm bikeshedding, your version's OK.

I'm not convinced there's really a bug, though: as far as I can tell we
*only* use the xid for matching call and response, so if it's changed it
doesn't affect what any later code does.

--b.

> 
> --b.
> 
> > 
> > Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>
> > ---
> >  fs/nfsd/nfs4recover.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index 66eaeb1..1abe9ed 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -753,6 +753,11 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> >  	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
> >  		return -EFAULT;
> >  
> > +	/* ensure that the xid has not been changed */
> > +	if (cup->cu_msg.cm_xid != xid) {
> > +		return -EFAULT;
> > +	}
> > +
> >  	wake_up_process(cup->cu_task);
> >  	return mlen;
> >  }
> > -- 
> > 2.7.4

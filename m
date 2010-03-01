From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: remove unnecessary svc_xprt_put
Date: Mon, 1 Mar 2010 09:44:39 -0500
Message-ID: <20100301144439.GD17660@fieldses.org>
References: <19336.19524.469529.431210@notabene.brown> <20100226225416.GF26598@fieldses.org> <4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown> <4B8885A1.500@opengridcomputing.com> <20100301152310.750f3504@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48674 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119Ab0CAOnd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 09:43:33 -0500
In-Reply-To: <20100301152310.750f3504-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 03:23:10PM +1100, Neil Brown wrote:
> On Fri, 26 Feb 2010 20:38:25 -0600
> Tom Tucker <tom@opengridcomputing.com> wrote:
> 
> > Neil Brown wrote:
> > > On Fri, 26 Feb 2010 18:40:58 -0600
> > > Tom Tucker <tom@opengridcomputing.com> wrote:
> > >
> > >   
> > >> J. Bruce Fields wrote:
> > >>     
> > >>> On Sat, Feb 27, 2010 at 09:33:40AM +1100, Neil Brown wrote:
> > >>>     
> > >>>       
> > >>>> [I found this while looking for the current refcount problem
> > >>>>  that triggers a warning in svc_recv.  This isn't that bug
> > >>>>  but is a different refcount bug - NB]
> > >>>>       
> > >>>>         
> > >>>     
> > >>>       
> > >> I seem to recall that we added that reference for  a reason. There was 
> > >> an issue with unmount while there were deferrals pending. That's why the 
> > >> reference was added.
> > >>
> > >> Tom
> > >>     
> > >
> > > What reference?
> > > What I (thought I) found was code that was dropping a reference which it
> > > didn't hold.  Are you saying that it is supposed to be holding a reference
> > > here, but isn't, or that it really is holding a reference here and I didn't
> > > see it?
> > >   
> > 
> > Here's the commit that I was thinking of... 
> > 22945e4a1c7454c97f5d8aee1ef526c83fef3223
> > 
> > I think this change adds the bug that you are now fixing. It fixed one 
> > problem, but added another that you have now resolved.
> > 
> > What do you guys think?
> 
> Yes,  I see what you are saying.
> 
> I agree that commit did fix a problem, but inadvertently introduced a new one.

Agreed.  So it looks to there's nothing additional here to fix.
(Correct me if I'm overlooking something.)

--b.

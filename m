From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/4] nfs: prepare to share nfs_set_port
Date: Wed, 20 Aug 2008 17:03:48 -0400
Message-ID: <20080820210348.GF21226@fieldses.org>
References: <20080820200827.GC21226@fieldses.org> <1219263023-22592-1-git-send-email-bfields@citi.umich.edu> <1219263023-22592-2-git-send-email-bfields@citi.umich.edu> <1219263023-22592-3-git-send-email-bfields@citi.umich.edu> <76bd70e30808201323h32debdeaj31577cd19b87612e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49709 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbYHTVEF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 17:04:05 -0400
In-Reply-To: <76bd70e30808201323h32debdeaj31577cd19b87612e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2008 at 04:23:23PM -0400, Chuck Lever wrote:
> On Wed, Aug 20, 2008 at 4:10 PM, J. Bruce Fields <bfields@citi.umich.edu> wrote:
> > We plan to use this function elsewhere.
> >
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/nfs/internal.h |   20 ++++++++++++++++++++
> >  fs/nfs/super.c    |   19 -------------------
> >  2 files changed, 20 insertions(+), 19 deletions(-)
> >
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index 24241fc..0b30f24 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -276,3 +276,23 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
> >                PAGE_SIZE - 1) >> PAGE_SHIFT;
> >  }
> >
> > +
> 
> Extra blank line here.
> 
> > +/*
> > + * Set the port number in an address.  Be agnostic about the address
> > + * family.
> > + */
> > +static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
> > +{
> > +       switch (sap->sa_family) {
> > +       case AF_INET: {
> > +             struct sockaddr_in *ap = (struct sockaddr_in *)sap;
> > +             ap->sin_port = htons(port);
> > +             break;
> > +       }
> > +       case AF_INET6: {
> > +              struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
> > +              ap->sin6_port = htons(port);
> > +              break;
> > +       }
> > +       }
> > +}
> 
> Before Trond sees this and busts a blood vessel... you should refactor
> the switch statement to get rid of the double braces.

OK, both done; results are the top four patches of

	git://linux-nfs.org/~bfields/linux.git for-trond

If you have other nfs/ipv6 patches laying around, would you rather queue
these up with them and send them in to Trond yourself?  Or do you want
me to?  Your choice.

--b.

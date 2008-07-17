From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Thu, 17 Jul 2008 10:48:52 -0400
Message-ID: <20080717144852.GA11759@fieldses.org>
References: <4869E8AB.4060905@aei.mpg.de> <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org> <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46956 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818AbYGQOs4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 10:48:56 -0400
In-Reply-To: <76bd70e30807170747r31af3280icf0bd3fdbde17bac-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 17, 2008 at 10:47:25AM -0400, Chuck Lever wrote:
> On Wed, Jul 16, 2008 at 3:06 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > The immediate problem seems like a kernel bug to me--it seems to me that
> > the calls to local daemons should be ignoring {min_,max}_resvport.  (Or
> > is there some way the daemons can still know that those calls come from
> > the local kernel?)
> 
> I tend to agree.  The rpcbind client (at least) does specifically
> require a privileged port, so a large min/max port range would be out
> of the question for those rpc_clients.

Any chance I could talk you into doing a patch for that?

--b.

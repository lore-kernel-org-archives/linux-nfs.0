From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Wed, 2 Jul 2008 17:08:35 -0400
Message-ID: <20080702210835.GC24850@fieldses.org>
References: <4869E8AB.4060905@aei.mpg.de> <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36371 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190AbYGBVJC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2008 17:09:02 -0400
In-Reply-To: <1215032676.7087.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 02, 2008 at 05:04:36PM -0400, Trond Myklebust wrote:
> On Wed, 2008-07-02 at 16:31 -0400, J. Bruce Fields wrote:
> > On Wed, Jul 02, 2008 at 04:00:21PM +0200, Carsten Aulbert wrote:
> > > Any hint for us how we shall proceed and maybe force the clients to also
> > > use ports > 1023? I think that would solve our problems.
> > 
> > I think the below (untested) would tell the client to stop demanding a
> > privileged port.
> 
> Alternatively, just change the values of /proc/sys/sunrpc/min_resvport
> and /proc/sys/sunrpc/max_resvport to whatever range of ports you
> actually want to use.

Whoops, yes, I missed those, thanks.

--b.

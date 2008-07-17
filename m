From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Thu, 17 Jul 2008 11:35:06 -0400
Message-ID: <1216308906.12588.12.camel@localhost>
References: <4869E8AB.4060905@aei.mpg.de>
	 <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de>
	 <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost>
	 <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org>
	 <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48445 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbYGQPfN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 11:35:13 -0400
In-Reply-To: <76bd70e30807170747r31af3280icf0bd3fdbde17bac-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-07-17 at 10:47 -0400, Chuck Lever wrote:
> I tend to agree.  The rpcbind client (at least) does specifically
> require a privileged port, so a large min/max port range would be out
> of the question for those rpc_clients.

'portmap' does indeed appear to check for privileged ports, but I can't
see any such checks in the rpcbind code.



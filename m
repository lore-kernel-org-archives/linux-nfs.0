From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 15:54:43 -0500
Message-ID: <1234472083.7190.124.camel@heimdal.trondhjem.org>
References: <20090211112318.GA29133@janus>
	 <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus>
	 <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus>
	 <1234451789.7190.38.camel@heimdal.trondhjem.org>
	 <20090212153634.GB28107@janus>
	 <1234462647.7190.53.camel@heimdal.trondhjem.org>
	 <20090212182943.GA1945@janus>
	 <1234465837.7190.62.camel@heimdal.trondhjem.org>
	 <03CEE6BB-D39D-47A5-BB6C-2FB3E206142F@oracle.com>
	 <1234467795.7190.70.camel@heimdal.trondhjem.org>
	 <D4DD97F7-B10B-43B5-B8F9-B7A489355A5E@oracle.com>
	 <1234470457.7190.106.camel@heimdal.trondhjem.org>
	 <2171ACCA-5CF5-425D-B7A4-CFB17DA61F75@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44358 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764AbZBLUyu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2009 15:54:50 -0500
In-Reply-To: <2171ACCA-5CF5-425D-B7A4-CFB17DA61F75@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-12 at 15:43 -0500, Chuck Lever wrote:
> On Feb 12, 2009, at 3:27 PM, Trond Myklebust wrote:
> > On Thu, 2009-02-12 at 15:11 -0500, Chuck Lever wrote:
> >> On Feb 12, 2009, at 2:43 PM, Trond Myklebust wrote:
> >>> On Thu, 2009-02-12 at 14:35 -0500, Chuck Lever wrote:
> >>>> I wasn't sure exactly where the compared addresses came from.  I  
> >>>> had
> >>>> assumed that they all came through the listener, so we wouldn't  
> >>>> need
> >>>> this kind of translation.  It shouldn't be difficult to map  
> >>>> addresses
> >>>> passed in via nlmclnt_init() to AF_INET6.
> >>>>
> >>>> But this is the kind of thing that makes "falling back" to an  
> >>>> AF_INET
> >>>> listener a little challenging.  We will have to record what flavor
> >>>> the
> >>>> listener is and do a translation depending on what listener family
> >>>> was
> >>>> actually created.
> >>>
> >>> Why? Should we care whether we're receiving IPv4 addresses or IPv6
> >>> v4-mapped addresses? They're the same thing...
> >>
> >> The problem is the listener family is now decided at run-time.  If an
> >> AF_INET6 listener can't be created, an AF_INET listener is created
> >> instead, even if CONFIG_IPV6 || CONFIG_IPV6_MODULE is enabled.  If an
> >> AF_INET listener is created, we get only IPv4 addresses in svc_rqst-
> >>> rq_addr.
> >
> > You're missing my point. Why should we care if it's one or the  
> > other? In
> > the NFSv4 case, we v4map all IPv4 addresses _unconditionally_ if it
> > turns out that CONFIG_IPV6 is enabled.
> >
> > IOW: we always compare IPv6 addresses.
> 
> The reason we might care in this case is nlm_cmp_addr() is executed  
> more frequently than nfs_sockaddr_match_ipaddr().
> 
> Mapping the server address in nlmclnt_init() means we translate the  
> server address once and are done with it.  We never have to map  
> incoming AF_INET addresses in NLM requests, and we don't have the  
> extra conditionals every time we go through nlm_cmp_addr().
> 
> This keeps nlm_cmp_addr() as simple as it can be: it compares only two  
> AF_INET addresses or two AF_INET6 addresses.

I don't see how that changes the general principle. All it means is that
you should be caching v4 mapped addresses instead of ipv4 addresses.
That would allow you to simplify nlm_cmp_addr() even further...

Trond


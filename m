From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Fri, 15 Aug 2008 16:47:10 -0400
Message-ID: <1218833230.7037.29.camel@localhost>
References: <20080701182250.GB21807@fieldses.org>
	 <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org>
	 <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com>
	 <20080717144852.GA11759@fieldses.org>
	 <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com>
	 <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com>
	 <20080730175308.GH12364@fieldses.org>
	 <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f@mail.gmail.com>
	 <76bd70e30807301501p5c0ba3c6i38fee02a1e606e31@mail.gmail.com>
	 <76bd70e30808151334i19822280j67a08b92b17582ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbYHOUsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Aug 2008 16:48:08 -0400
In-Reply-To: <76bd70e30808151334i19822280j67a08b92b17582ba-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-08-15 at 16:34 -0400, Chuck Lever wrote:
> Trond, NFS_MOUNT_FLAGMASK is used in nfs_init_server() and
> nfs4_init_server() for both legacy binary and text-based mounts.  This
> needs to be moved to a legacy-only path if we want to use the
> high-order 16 bits in the 'flags' field for text-based mounts.

We definitely want to do this. The point of introducing text-based
mounts was to allow us to add functionality without having to worry
about legacy binary mount formats. The mask should be there in order to
ensure that binary formats don't start enabling features that they
cannot support. There is no justification for applying it to the text
mount path.

> I reviewed the Solaris mount_nfs(1M) man page (I hope this is the
> correct place to look).  There doesn't appear to be a mount option to
> make Solaris NFS clients use a reserved port. Not sure if there's some
> other UI (like a config file in /etc).
> 
> FreeBSD and Mac OS both use "[no]resvport" as Mike pointed out
> earlier.  That's my vote for the new Linux mount option

Agreed: we should try to follow the standard set by existing
implementations wherever we can...

> [ Sidebar: I found this in the Mac OS mount_nfs(8) man page:
> 
>      noconn  Do not connect UDP sockets.  For UDP mount points, do not do a
>              connect(2).  This must be used for servers that do not reply to
>              requests from the standard NFS port number 2049.  It may also be
>              required for servers with more than one IP address if replies come
>              from an address other than the one specified in the requests.
> 
> An interesting consideration if we support connected UDP sockets for
> NFS at some point. ]

Hmm... Well, we already don't support servers that reply to a UDP
request from a different IP address, and I can't see that we should
really care. Aside from the fact that most clients will use TCP by
default these days, it is quite trivial for a server to track on which
interface a UDP request was received, and ensure that the reply is sent
on the same interface. In fact, we already do this in the Linux server
AFAICR...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

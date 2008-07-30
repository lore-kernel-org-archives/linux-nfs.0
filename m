From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Wed, 30 Jul 2008 18:13:04 -0400
Message-ID: <20080730221304.GB20739@fieldses.org>
References: <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org> <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com> <20080717144852.GA11759@fieldses.org> <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com> <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com> <20080730175308.GH12364@fieldses.org> <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48904 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951AbYG3WNJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 18:13:09 -0400
In-Reply-To: <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 30, 2008 at 03:33:38PM -0400, Chuck Lever wrote:
> On Wed, Jul 30, 2008 at 1:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > In any case, this all seems a bit orthogonal to the problem of what
> > ports the rpcbind client uses, right?
> 
> No, this is exactly the original problem.  The reason xprt_maxresvport
> is allowed to go larger than 1023 is to permit more NFS mounts.  There
> really is no other reason for it I can think of.
> 
> But it's broken (or at least inconsistent) behavior that max_resvport
> can go past 1023 in the first place.  The name is "max_resvport" --
> Maximum Reserved Port.  A port value of more than 1024 is not a
> reserved port.  These sysctls are designed to restrict the range of
> ports used when a _reserved_ port is requested, not when _any_ source
> port is requested. Trond's suggestion is an "off label" use of this
> facility.

We could do a better job of communicating what is and isn't a documented
usage, in that case.

Once people are already using an interface a certain way (and because we
told them to) discussions about whether it's really a correct use start
to seem a little academic.

> And rpcbind isn't the only kernel-level RPC service that requires a
> reserved port.  The kernel-level NSM code that calls user space, for
> example, is one such service.  In other words, rpcbind isn't the only
> service that could potentially hit this issue, so an rpcbind-only fix
> would be incomplete.
> 
> We already have an appropriate interface for kernel RPC services to
> request a non-privileged port.  The NFS client should use that
> interface.

I admit that would be nicer.

--b.

> Now, we don't have to change both at the same time.  We can introduce
> the mount option now; the default reserved port range is still good.
> And eventually folks using the sysctl will hit the rpcbind bug (or a
> lock recovery problem), trace it back to this issue, and change their
> mount options and reset their resvport sysctls.
> 
> At some later point, though, the maximum should be restricted to 1023.
> 
> >> Such an "insecure" mount option would then set
> >> RPC_CLNT_CREATE_NONPRIVPORT on rpc_clnt's created on behalf of the NFS
> >> client.
> >>
> >> I'm not married to the names of the options, or even using a mount
> >> option at all (although that seems like a natural place to put such a
> >> feature).
> >>
> >> Thoughts?
> 
> --
> Chuck Lever

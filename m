From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Wed, 30 Jul 2008 13:53:08 -0400
Message-ID: <20080730175308.GH12364@fieldses.org>
References: <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org> <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com> <20080717144852.GA11759@fieldses.org> <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com> <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com>
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
Received: from mail.fieldses.org ([66.93.2.214]:49778 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbYG3RxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 13:53:13 -0400
In-Reply-To: <76bd70e30807281355t4890a9b2q6960d79552538f60-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 28, 2008 at 04:55:50PM -0400, Chuck Lever wrote:
> On Thu, Jul 17, 2008 at 11:11 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > On Thu, Jul 17, 2008 at 10:48 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> On Thu, Jul 17, 2008 at 10:47:25AM -0400, Chuck Lever wrote:
> >>> On Wed, Jul 16, 2008 at 3:06 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>> > The immediate problem seems like a kernel bug to me--it seems to me that
> >>> > the calls to local daemons should be ignoring {min_,max}_resvport.  (Or
> >>> > is there some way the daemons can still know that those calls come from
> >>> > the local kernel?)
> >>>
> >>> I tend to agree.  The rpcbind client (at least) does specifically
> >>> require a privileged port, so a large min/max port range would be out
> >>> of the question for those rpc_clients.
> >>
> >> Any chance I could talk you into doing a patch for that?
> >
> > I can look at it when I get back next week.
> 
> I've been pondering this.
> 
> It seems like the NFS client is a rather unique case for using
> unprivileged ports; most or all of the other RPC clients in the kernel
> want to use privileged ports pretty much all the time, and have
> learned to switch this off as needed and appropriate.  We even have an
> internal API feature for doing this: the RPC_CLNT_CREATE_NONPRIVPORT
> flag to rpc_create().
> 
> And instead of allowing a wide source port range, it would be better
> for the NFS client to use either privileged ports, or unprivileged
> ports, but not both, for the same mount point.  Otherwise we could be
> opening ourselves up for non-deterministic behavior: "How come
> sometimes I get EPERM when I try to mount my NFS servers, but other
> times the same mount command works fine?" or "Sometimes after a long
> idle period my NFS mount points stop working, and all the programs
> running on the mount point get EACCES."
> 
> It seems like a good solution would be to:
> 
> 1.  Make the xprt_minresvport and xprt_maxresvport sysctls mean what
> they say: they are _reserved_ port limits.  Thus xprt_maxresvport
> should never be allowed to be larger than 1023, and xprt_minresvport
> should always be made to be strictly less than xprt_maxresvport; and

That would break existing setups: so, someone googles for "nfs linux
large numbers of mounts" and comes across:

	http://marc.info/?l=linux-nfs&m=121509091004851&w=2

They add

	echo 2000 >/proc/sys/sunrpc/max_resvport

to their initscripts, and their problem goes away.  A year later, with
this incident long forgotten, they upgrade their kernel, start getting
failed mounts, and in the worst case end up debugging the whole problem
from scratch again.

> 2.  Introduce a mechanism to specifically enable the NFS client to use
> non-privileged ports.  It could be a new mount option like "insecure"
> (which is what some other O/Ses use) or "unpriv-source-port" for
> example.  I tend to dislike the former because such a feature is
> likely to be quite useful with Kerberos-authenticated NFS, and
> "sec=krb5,insecure" is probably a little funny looking, but
> "sec=krb5,unpriv-source-port" makes it pretty clear what is going on.

But I can see the argument for the mount option.

Maybe we could leave the meaning of the sysctls alone, and allowing
noresvport as an alternate way to allow use of nonreserved ports?

In any case, this all seems a bit orthogonal to the problem of what
ports the rpcbind client uses, right?

--b.

> 
> Such an "insecure" mount option would then set
> RPC_CLNT_CREATE_NONPRIVPORT on rpc_clnt's created on behalf of the NFS
> client.
> 
> I'm not married to the names of the options, or even using a mount
> option at all (although that seems like a natural place to put such a
> feature).
> 
> Thoughts?
> 
> -- 
> Chuck Lever

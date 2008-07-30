From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/8] SUNRPC: Add kernel build option to disable
	server-side use of rpcbind v3/v4
Date: Wed, 30 Jul 2008 12:18:24 -0400
Message-ID: <20080730161824.GC12364@fieldses.org>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net> <20080630224609.24887.20585.stgit@ellison.1015granger.net> <20080718234241.GE15850@fieldses.org> <76bd70e30807211230y4b7c2b21qa89d8cca05e08dab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34663 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbYG3QS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 12:18:27 -0400
In-Reply-To: <76bd70e30807211230y4b7c2b21qa89d8cca05e08dab-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2008 at 03:30:10PM -0400, Chuck Lever wrote:
> On Fri, Jul 18, 2008 at 7:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Mon, Jun 30, 2008 at 06:46:09PM -0400, Chuck Lever wrote:
> >> Allow distributions to use the legacy behavior until they integrate an
> >> appropriate user-space rpcbind daemon that can support IPv6 RPC services.
> >>
> >> I tried adding some logic to fall back if (un)registering with a v4
> >> protocol request failed, but there are too many corner cases.  So I just
> >> made it a compile-time switch that distributions can throw when they've
> >> replaced portmapper with rpcbind.
> >
> > OK, I see you answered my last question....  Hm.  What were the corner
> > cases?
> 
> The obvious ones:  is there a daemon running at all, and is it
> listening?  If I try v4 but that doesn't work, then I retry with v3...
> if that doesn't work, then I try v2.  Is it OK if I was able to
> register an AF_INET6 service via v2?
> 
> Certainly all this is possible to code up, but it didn't seem worth
> the complexity.

If it's really painful, OK.

But I'm nervous about slighting backwards compatibility.  It's another
thing people can mess up when they build their own stuff.  And are
people going to be able to bisect problems in nfs-utils without building
their own kernel as well?

--b.

> 
> >>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >>
> >>  fs/Kconfig |   22 ++++++++++++++++++++++
> >>  1 files changed, 22 insertions(+), 0 deletions(-)
> >>
> >>
> >> diff --git a/fs/Kconfig b/fs/Kconfig
> >> index 8cf8ee2..6148f4c 100644
> >> --- a/fs/Kconfig
> >> +++ b/fs/Kconfig
> >> @@ -1799,6 +1799,28 @@ config SUNRPC_XPRT_RDMA
> >>
> >>         If unsure, say N.
> >>
> >> +config SUNRPC_REGISTER_V4
> >> +     bool "Register local RPC services via rpcbind v4 (EXPERIMENTAL)"
> >> +     depends on SUNRPC && EXPERIMENTAL
> >> +     default n
> >> +     help
> >> +       Sun added support for registering RPC services at an IPv6
> >> +       address by creating two new versions of the rpcbind protocol
> >> +       (RFC 1833).
> >> +
> >> +       This option enables support in the kernel RPC server for
> >> +       registering kernel RPC services via version 4 of the rpcbind
> >> +       protocol.  If you enable this option, you must run a portmapper
> >> +       daemon that supports rpcbind protocol version 4.
> >> +
> >> +       Serving NFS over IPv6 from knfsd (the kernel's NFS server)
> >> +       requires that you enable this option and use a portmapper that
> >> +       supports rpcbind version 4.
> >> +
> >> +       If unsure, say N to get traditional behavior (register kernel
> >> +       RPC services using only rpcbind version 2).  Distributions
> >> +       using the legacy Linux portmapper daemon must say N here.
> >> +
> >>  config RPCSEC_GSS_KRB5
> >>       tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
> >>       depends on SUNRPC && EXPERIMENTAL
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> 
> 
> -- 
>  "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
> --Dr. Evil

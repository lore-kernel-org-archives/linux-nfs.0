From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Thu, 17 Jul 2008 10:27:39 -0400
Message-ID: <20080717142739.GC10799@fieldses.org>
References: <4869E8AB.4060905@aei.mpg.de> <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org> <487EDE57.4070100@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34209 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754795AbYGQO1k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 10:27:40 -0400
In-Reply-To: <487EDE57.4070100-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 17, 2008 at 07:53:27AM +0200, Carsten Aulbert wrote:
> Hi all,
> 
> J. Bruce Fields wrote:
> 
> >> Changing /proc/sys/sunrpc/max_resvport to 1023 again resolves this
> >> issue, however defeats the purpose for the initial problem. I still need
> >> to look into the code for hte portmapper, but is it easily possible that
> >> the portmapper would accept nfsd requests from "insecure" ports also?
> >> Since e are (mostly) in a controlled environment that should not pose a
> >> problem.
> >>
> >> Anyone with an idea?
> > 
> > The immediate problem seems like a kernel bug to me--it seems to me that
> > the calls to local daemons should be ignoring {min_,max}_resvport.  (Or
> > is there some way the daemons can still know that those calls come from
> > the local kernel?)
> 
> I just found this in the Makefile for the portmapper:
> 
> # To disable tcp-wrapper style access control, comment out the following
> # macro definitions.  Access control can also be turned off by providing
> # no access control tables. The local system, since it runs the portmap
> # daemon, is always treated as an authorized host.
> 
> HOSTS_ACCESS= -DHOSTS_ACCESS
> #WRAP_LIB = $(WRAP_DIR)/libwrap.a
> WRAP_LIB = -lwrap
> 

Slightly off-topic, but I'm confused by the comment:

> # Comment out if your RPC library does not allocate privileged ports for
> # requests from processes with root privilege, or the new portmap will
> # always reject requests to register/unregister services on privileged
> # ports.

Shouldn't that be "on unprivileged ports"?

> You can find out by running "rpcinfo -p"; if all mountd and NIS
> # daemons use a port >= 1024 you should probably disable the next line.

Doesn't rpcinfo -p just tell you which port those daemons are listening
on, not which ports they'll use for contacting the portmapper?  A priori
I don't see what one would have to do with the other.

> 
> CHECK_PORT = -DCHECK_PORT
> 
> I'll try to head down the road of not checking for the ports anymore -
> on exposed ports I could block the listening daemons from the outside
> world by iptables.

It's just the port that the portmapper itself listens on that needs to
be firewalled, right?

> Not nice, but probably a solution (and yet another
> custom package for us).
> 
> Anyone who knows a good reason not to walk this route?

I guess the risk is that any old userland process on the server can now
advertise nfsd service, and the clients end up contacting it instead of
the kernel's nfsd.

--b.

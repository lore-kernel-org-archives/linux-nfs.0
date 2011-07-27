Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115Ab1G0GiG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 02:38:06 -0400
Subject: Re: [Libtirpc-devel] [PATCH] Autofs configure fails to detect IPv6
 when libtirpc is enabled
From: Ian Kent <ikent@redhat.com>
To: Chuck Lever <chucklever@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        autofs mailing list <autofs@linux.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
In-Reply-To: <1311737951.3473.28.camel@perseus.themaw.net>
References: <1311683346-16881-1-git-send-email-steved@redhat.com>
	 <8A84CF7D-9579-4645-AE5D-FE8358F466C0@gmail.com>
	 <4E2F2DE6.5030500@RedHat.com>  <1311728231.3473.7.camel@perseus.themaw.net>
	 <1311729784.3473.14.camel@perseus.themaw.net>
	 <A8F3853A-9C75-4F65-8EEB-88DD13C3FF9B@gmail.com>
	 <1311734445.3473.19.camel@perseus.themaw.net>
	 <8A86A2AE-A1C7-473E-931A-CF03BD690CE6@gmail.com>
	 <1311737951.3473.28.camel@perseus.themaw.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Jul 2011 14:37:51 +0800
Message-ID: <1311748671.3473.29.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 11:39 +0800, Ian Kent wrote:
> On Tue, 2011-07-26 at 23:30 -0400, Chuck Lever wrote:
> > On Jul 26, 2011, at 10:40 PM, Ian Kent wrote:
> > 
> > > On Tue, 2011-07-26 at 22:09 -0400, Chuck Lever wrote:
> > >> On Jul 26, 2011, at 9:23 PM, Ian Kent wrote:
> > >> 
> > >>> On Wed, 2011-07-27 at 08:57 +0800, Ian Kent wrote:
> > >>>> On Tue, 2011-07-26 at 17:13 -0400, Steve Dickson wrote:
> > >>>>> 
> > >>>>> On 07/26/2011 10:50 AM, Chuck Lever wrote:
> > >>>>>> 
> > >>>>>> On Jul 26, 2011, at 2:29 PM, Steve Dickson wrote:
> > >>>>>> 
> > >>>>>>> From: Ian Kent <raven@themaw.net>
> > >>>>>>> 
> > >>>>>>> The IPv6 client functions clntudp6_bufcreate(), clntudp6_create and
> > >>>>>>> clnttcp6_create and the server functions svcudp6_bufcreate(),
> > >>>>>>> svctcp6_create() and svcudp6_create() are not included in the library
> > >>>>>>> whe libtirpc is built.
> > >>>>>> 
> > >>>>>> Are these part of the libtirpc standard API?  I'm not sure why we would need them if, say, Solaris does not support these.
> > >>>>> It appears they are not since they are not mentioned the man pages.....
> > >>>>> But, at least in the autofs code, they are expected
> > >>>>>  https://bugzilla.redhat.com/show_bug.cgi?id=711956#c0
> > >>>>> 
> > >>>>> Ian, where else are these routines defined? 
> > >>>> 
> > >>>> Now that I look I can't find the original source tar that was used for
> > >>>> libtirpc, thought I had it.
> > >>> 
> > >>> Found what I had.
> > >>> 
> > >>> AFAICT what I think was the original source doesn't have any IPv6 code
> > >>> that I can see.
> > >>> 
> > >>> Worse, these functions were excluded with the "#ifdef INET6_NOT_USED"
> > >>> macro as far back as libtirpc version 0.1.5 so, my bad, sorry.
> > >>> 
> > >>>> 
> > >>>> The story is that long ago when I changed autofs to use libtirpc (to
> > >>>> make it ready for IPv6) I found these functions in the source and they
> > >>>> were (obviously) the IPv6 counterparts for the corresponding IPv4
> > >>>> functions which I was already using, so I used them. It took me quite a
> > >>>> while to realize my code wasn't working and then I found that somewhere
> > >>>> along the line they have been excluded, oops!
> > >>>> 
> > >>>> If there are to be no IPv6 counterparts for the corresponding IPv4
> > >>>> functions which functions should I use then?
> > >>> 
> > >>> So what can I use?
> > >>> 
> > >>> It seems to me that these functions would be useful for people porting
> > >>> code that uses the corresponding IPv4 functions so could we define them
> > >>> please. At some point someone must have had that same idea ....
> > >> 
> > >> It looks to me like these functions were part of an original attempt
> > >> at IPv6 support that was abandoned long ago.  They are not part of
> > >> TI-RPC, but as you observed, they are merely IPv6 versions of the
> > >> legacy RPC API. I don't see these implemented in glibc, for example.
> > >> 
> > >> For IPv6 support, use functions that are part of the modern libtirpc
> > >> API.  This is described in Sun doc 816-1435.  You probably will be
> > >> most successful with the "simplified interface" which is described in
> > >> Chapter 4. You might need somewhat more extensive surgery since I'm
> > >> guessing you have separate code paths to invoke the IPv4 and IPv6
> > >> legacy RPC functions; generally speaking that should not be needed
> > >> when using the libtirpc API.
> > > 
> > > I doubt the simplified interface will be adequate since this code was
> > > written because of a need for greater control over timeouts. Perhaps
> > > that won't be the case, I don't know yet.
> > 
> > If you want control over connection timeouts, use the expert-level or
> > bottom-level interfaces.  Otherwise you can set per-RPC timeouts when
> > clnt_call(3t) is invoked.  nfs-utils has some example code
> > (support/nfs/rpc_socket.c is one place to look).
> > 
> > > Your suggestion amounts to saying I need to re-write all my RPC
> > code.
> > 
> > The substantial change with client-side TI-RPC is how CLIENTs are
> > created.  The other RPC operations are similar or the same as they
> > were with the legacy API.  Once you get over getnetconfigent(3t) it's
> > really not as bad as it looks.
> > 
> 
> Sure, but it's the dependent code in autofs that uses the RPC routines
> that will force me to keep the interface. But, like I said, it may be a
> non-issue since I can lift these routines straight out of libtirpc (as
> long as I attribute copyright according to the comment in the source
> file).

That's not going to be straight forward either.

> 
> Ian



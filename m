Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:26908 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755981Ab0IUJIW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 05:08:22 -0400
Date: Tue, 21 Sep 2010 11:08:21 +0200
From: Jan =?utf-8?Q?R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Message-ID: <20100921090820.GF4358@sith.mimuw.edu.pl>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl> <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com> <20100920153157.GA20589@sith.mimuw.edu.pl> <02C38759-5236-454B-8F7B-02F9419B1532@oracle.com> <20100920164856.GA20925@sith.mimuw.edu.pl> <FC6FA83D-52D7-411A-A18F-4A143A60992E@oracle.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <FC6FA83D-52D7-411A-A18F-4A143A60992E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 20 Sep 2010, Chuck Lever wrote:

> 
> On Sep 20, 2010, at 12:48 PM, Jan Rękorajski wrote:
> 
> > On Mon, 20 Sep 2010, Chuck Lever wrote:
> > 
> >> 
> >> On Sep 20, 2010, at 11:31 AM, Jan Rękorajski wrote:
> >> 
> >>> On Mon, 20 Sep 2010, Chuck Lever wrote:
> >>> 
> >>>> 
> >>>> On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:
> >>>> 
[snip]
> > 
> >> None of NFS's RPC daemons allow you to set a bind address, with one
> >> exception.  rpc.statd allows one to specify a "bind address" in the
> >> form of a host name for reasons specific to the NSM protocol.
> > 
> > I may be wrong here, but maybe it's because it was always portmapper
> > doing the binding, so if portmapper couldn't then no one thought of
> > adding this to RPC daemons.
> 
> If rpc.mountd is running on a host, and rpcbind is not, it doesn't
> matter.  A port scanner can still find and attack the open mountd
> port.  The best and safest approach, IMO, is to use a firewall, and
> then test it with a remote port scanner service.  Our rpcbind
> implementation has tcp_wrapper already built in, for instance, but I
> use the iptables firewall in Fedora 13 (and, I keep RPC services on
> hosts inside the firewall, not on the firewall itself).

You're right, but try to see that rpcbind is not just a part of NFS
implementation.  It is an RPC port mapper daemon that happens to be
mostly used by NFS and is maintained by NFS people.  So rpc.mountd
security should be a separate issue, especially if it can run without a
portmapper.

> [ ... snipped ... ]
> 
> >>> Second thing is a host for vservers
> >>> (http://linux-vserver.org), I need to run portmapper in guests but
> >>> rpcbind listening on INADDR_ANY is not letting me.
> >> 
> >> Can you say more?  Maybe it's a bug.
> > 
> > It's more of a design flaw, vserver is an isolation techique, and if I
> > bind to some port on INADDR_ANY on host then I can't bind to that
> > port on guests. I don't know the implementation details, but network
> > interfaces other than lo are not (maybe can't be) isolated enough.
> 
> The problem is the guest listeners get EADDRINUSE, or equivalent,
> since they are sharing a network namespace with the host?

It appears so, sorry that I can't elaborate more on this.

> >>> And finally it's good
> >>> to be consistent, it's strange to me that someone may want to limit only
> >>> the UDP part of portmapper (modulo network issues you mentioned).
> >> 
> >> "-h" was added to address an issue specific to Linux UDP sockets.
> >> It's not a feature, but a bug fix that is UDP-specific.  TCP doesn't
> >> need this bug fix.
> > 
> > Of course, but why not change a bugfix into a feature?
> 
> If we want to add this feature properly, we will have to change a
> broad range of user space components.  Therefore it will be a
> non-trivial undertaking.

IMO adding this to rpcbind won't hurt anybody, it's simple and may be a good
starting point to work on the rest of the daemons.  Besides I do have rpcbind
with my patch running and NFS and other RPC services are working just fine.

-- 
Jan Rękorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio

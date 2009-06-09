From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 9 Jun 2009 13:01:26 -0400
Message-ID: <6FC2F8D7-91F4-4EED-AFBF-F50EEFB752EA@oracle.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <4A2CD550.4090609@RedHat.com> <20090608071026.0b57fff8@tupile.poochiereds.net> <4A2D13DF.2040105@RedHat.com> <467512DC-2A83-4432-A29C-1688B021A1F5@oracle.com> <4A2D2862.3090303@RedHat.com> <20090608124140.3fa02688@tlielax.poochiereds.net> <CAFCBD84-FFEB-40FB-9594-40E4E17A8BE3@oracle.com> <4A2E503E.1080809@RedHat.com> <6C2F758F-4274-4952-B139-FA854B7BA48B@oracle.com> <4A2E7646.1030602@RedHat.com> <42F5C949-9BBB-4A35-8454-F56BF7CD904D@or
 acle.com> <4A2E82AD.7070908@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:44241 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756923AbZFIRBw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2009 13:01:52 -0400
In-Reply-To: <4A2E82AD.7070908-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 9, 2009, at 11:41 AM, Steve Dickson wrote:
> Chuck Lever wrote:
>>
>> I think you are making my argument for me.  The fact that TI-RPC  
>> support
>> could go into glibc (but hasn't because of politics) suggests that
>> --enable-tirpc has nothing to do with a particular library.  It is
>> solely a feature knob, just like all the other --enable switches in
>> ./configure.
> So you agree that --enable-tirpc and --enable-ipv6 are the same thing
> since you can't have ipv6 without libtirpc and only reason to
> have libtirpc is ipv6...

I don't agree that they are the same.  There are other reasons to  
support TI-RPC, even in IPv4-only environments.

TI-RPC was invented to sink as many transport dependencies into the  
library code as possible, so RPC applications don't have to deal with  
the transport layer unless absolutely necessary.  They no longer have  
to worry about port numbers and sockaddrs, and the rest.  So, top  
level TI-RPC client APIs (rpc_call(3t)) take a hostname and an RPC  
program/version/procedure, and server side APIs (rpc_reg(3t)) take an  
RPC program/version, and the library handles all the network details  
for you.

So, TI-RPC is a prerequisite for IPv6, and IPv6 is a _subset_ of the  
features that TI-RPC provides.  But, you can use TI-RPC in  
environments that do not have any IPv6 support whatsoever.  The TI-RPC  
transport switch can be used in much the same way as the kernel's RPC  
transport switch -- new transport capabilities are added to the  
library, and TI-RPC applications now have much less work to do to  
support them.

Specifically in the case of nfs-utils, we are adopting TI-RPC to  
support IPv6.  But, that doesn't make IPv6 and TI-RPC equivalent; it  
makes IPv6 the driver of TI-RPC adoption.  Once TI-RPC support is  
enabled, IPv6 comes for free -- it's actually very little extra work  
to provide IPv6 support once TI-RPC support is available.

If TI-RPC support is not available, then IPv6 support is moot.  If it  
is available, then IPv6 support should be controlled via a run-time  
switch, not via a build-time switch.  Thus, --enable-ipv6 should go  
away.

For example: suppose we add sctp transport capabilities to libtirpc.   
Then, does it make sense to build nfs-utils with --enable-ipv6 to get  
that support?  No, it makes sense to build nfs-utils with --enable- 
tirpc, and then use /etc/netconfig to enable sctp transports for nfs- 
utils, because you'll have to dink around in /etc/netconfig whether we  
use --enable-ipv6 or --enable-tirpc.

>>>> I honestly don't see a distinction between --enable-gss, which adds
>>>> additional features in nfs-utils, but requires an additional  
>>>> library,
>>>> and --enable-tirpc, which adds additional features, but requires an
>>>> additional library.
>>> -enable-gss cause two daemon to be build and get installed which
>>> adds the Secure NFS functionality. --enable-tirpc only causes code
>>> paths to change, it add no functionality unless Ipv6 is enabled.
>>
>> TI-RPC is not just an IPv6 enabler.  It also has interoperability
>> implications.  Support for rpcbind v3/v4 has no dependence on  
>> IPv6.  You
>> can use rpcbind v3 or v4 requests over IPv4, for example, which  
>> provides
>> a significantly richer set of functionality.  One area of non-IPv6
>> interest would be support for registering local services via  
>> AF_UNIX --
>> this type of registering is actually authenticated, so it is a good
>> security feature.
> But again, the only reason rpcbind is around is because it has
> IPv6 support. Please believe, I was a bit nervous switch out the
> portmapper since it was a very stable piece of code since it
> very rarely changed...

rpcbind provides additional features, and supports new versions of the  
rpcbind protocol.  ONE REASON you might want these features is IPv6  
support.  You have more secure local registration, and also a --warm- 
start option, for example; both desirable features.  Neither of those  
have anything to do with IPv6.

>>> So that's way I think all that is needed is an --enable-ipv6 flag.
>>
>> Actually, the new statd is built only if --enable-tirpc is set.  So,
>> yes:  new code _and_ new components are provided if --enable-tirpc is
>> set.  TI-RPC is very similar to Secure NFS functionality.  Secure NFS
>> provides support for new RPC features known as RPCSEC GSS, and
>> --enable-tirpc provides support for new RPC features known as TI-RPC.
>> So again, I don't see any philosophical difference between --enable- 
>> gss
>> and --enable-tirpc.
> And the only reason statd need to use the new code is for IPv6
> support, true?

Yes, but I don't see why that's relevant.  Again, IPv6 may be a driver  
for our adoption of TI-RPC, but that doesn't mean the two are  
equivalent.

>> However, --enable-ipv6 is unnecessary because we want, and have,
>> run-time switches for that support.  We are forced to, because nfs- 
>> utils
>> has to run on kernels which may or may not support IPv6.
>
>> I am continuing to argue this point because getting rid of
>> --enable-tirpc will make our jobs a lot harder.  The reason this  
>> knob is
>> there is to firewall the new code and keep upstream nfs-utils  
>> stable as
>> we integrate more and more support for TI-RPC.
> Understood... And I applaud the effort both you and Jeff are making...
>
>> If we call it --enable-ipv6, many distributions will say "so what, i
>> don't need that" and leave it turned off.  We won't get the kind of  
>> soak
>> time we really need.
> And if we call --enable-tirpc they will not know that they are  
> enabling
> IPv6 code in statd, true?

The new man page for statd explains how that works; inet6 can be  
disabled for statd, if desired, via the run-time switch provided in / 
etc/netconfig.

But even if statd can respond to NSM requests from IPv6, that really  
doesn't matter, unless the rest of the system is ready for IPv6.  It's  
simply a piece of the infrastructure.  AFAICT there is no harm in  
having an IPv6-enabled statd on a system that doesn't otherwise  
support IPv6.

> But in the end, I guess I have confidence that the distros will do  
> what is
> best for them... and if they have customers that need this support  
> they
> will enable it. If not, they will not enable it, regardless of what
> upstream does...

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

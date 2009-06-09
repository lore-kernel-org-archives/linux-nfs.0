From: Steve Dickson <SteveD@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 09 Jun 2009 11:41:33 -0400
Message-ID: <4A2E82AD.7070908@RedHat.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <4A2CD550.4090609@RedHat.com> <20090608071026.0b57fff8@tupile.poochiereds.net> <4A2D13DF.2040105@RedHat.com> <467512DC-2A83-4432-A29C-1688B021A1F5@oracle.com> <4A2D2862.3090303@RedHat.com> <20090608124140.3fa02688@tlielax.poochiereds.net> <CAFCBD84-FFEB-40FB-9594-40E4E17A8BE3@oracle.com> <4A2E503E.1080809@RedHat.com> <6C2F758F-4274-4952-B139-FA854B7BA48B@oracle.com> <4A2E7646.1030602@RedHat.com> <42F5C949-9BBB-4A35-8454-F56BF7CD904D@or
 acle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45048 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbZFIPoo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 11:44:44 -0400
In-Reply-To: <42F5C949-9BBB-4A35-8454-F56BF7CD904D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> 
> I think you are making my argument for me.  The fact that TI-RPC support
> could go into glibc (but hasn't because of politics) suggests that
> --enable-tirpc has nothing to do with a particular library.  It is
> solely a feature knob, just like all the other --enable switches in
> ./configure.
So you agree that --enable-tirpc and --enable-ipv6 are the same thing
since you can't have ipv6 without libtirpc and only reason to
have libtirpc is ipv6...

> 
>>> I honestly don't see a distinction between --enable-gss, which adds
>>> additional features in nfs-utils, but requires an additional library,
>>> and --enable-tirpc, which adds additional features, but requires an
>>> additional library.
>> -enable-gss cause two daemon to be build and get installed which
>> adds the Secure NFS functionality. --enable-tirpc only causes code
>> paths to change, it add no functionality unless Ipv6 is enabled.
> 
> TI-RPC is not just an IPv6 enabler.  It also has interoperability
> implications.  Support for rpcbind v3/v4 has no dependence on IPv6.  You
> can use rpcbind v3 or v4 requests over IPv4, for example, which provides
> a significantly richer set of functionality.  One area of non-IPv6
> interest would be support for registering local services via AF_UNIX --
> this type of registering is actually authenticated, so it is a good
> security feature.
But again, the only reason rpcbind is around is because it has 
IPv6 support. Please believe, I was a bit nervous switch out the 
portmapper since it was a very stable piece of code since it
very rarely changed... 
 
> 
>> So that's way I think all that is needed is an --enable-ipv6 flag.
> 
> Actually, the new statd is built only if --enable-tirpc is set.  So,
> yes:  new code _and_ new components are provided if --enable-tirpc is
> set.  TI-RPC is very similar to Secure NFS functionality.  Secure NFS
> provides support for new RPC features known as RPCSEC GSS, and
> --enable-tirpc provides support for new RPC features known as TI-RPC. 
> So again, I don't see any philosophical difference between --enable-gss
> and --enable-tirpc.
And the only reason statd need to use the new code is for IPv6 
support, true? 

> 
> However, --enable-ipv6 is unnecessary because we want, and have,
> run-time switches for that support.  We are forced to, because nfs-utils
> has to run on kernels which may or may not support IPv6.

> 
> I am continuing to argue this point because getting rid of
> --enable-tirpc will make our jobs a lot harder.  The reason this knob is
> there is to firewall the new code and keep upstream nfs-utils stable as
> we integrate more and more support for TI-RPC.
Understood... And I applaud the effort both you and Jeff are making...

> 
> If we call it --enable-ipv6, many distributions will say "so what, i
> don't need that" and leave it turned off.  We won't get the kind of soak
> time we really need.
And if we call --enable-tirpc they will not know that they are enabling 
IPv6 code in statd, true?

But in the end, I guess I have confidence that the distros will do what is 
best for them... and if they have customers that need this support they 
will enable it. If not, they will not enable it, regardless of what 
upstream does...

steved.

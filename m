From: Steve Dickson <SteveD@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 09 Jun 2009 08:06:22 -0400
Message-ID: <4A2E503E.1080809@RedHat.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <4A2CD550.4090609@RedHat.com> <20090608071026.0b57fff8@tupile.poochiereds.net> <4A2D13DF.2040105@RedHat.com> <467512DC-2A83-4432-A29C-1688B021A1F5@oracle.com> <4A2D2862.3090303@RedHat.com> <20090608124140.3fa02688@tlielax.poochiereds.net> <CAFCBD84-FFEB-40FB-9594-40E4E17A8BE3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39272 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbZFIMJb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 08:09:31 -0400
In-Reply-To: <CAFCBD84-FFEB-40FB-9594-40E4E17A8BE3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>>
>>>>
>>>>> I guess I just don't see why there has to be two switches for
>>>>> this feature...
>>>>
>>>> Because people seem to want to disable IPv6 support completely on their
>>>> systems...  Because there is a striking lack of infrastructure for IPv6
>>>> support (including GUIs for configurating ip6tables, lack of IPv6
>>>> support in NetworkManager, no IPv6 support in tcp_wrappers,
>>>> inability to
>>>> disable IPv6 support in the kernel without hacking it out of
>>>> /etc/modprobe.conf, and so on)...  Because TI-RPC is one level of
>>>> complexity, and IPv6 adds more complexity...
>>>>
>>>> We can probably remove --enable-ipv6, and just stick with
>>>> --enable-tirpc, which implies IPv6 support, if you prefer that.
>>> Actually I would like to do just the opposite... remove --enable-tirpc
>>> and stick with --enable-ipv6...
>>>
>>>> But it's a strange argument, when we have --enable-mount,
>>>> --enable-nfsv4,
>>>> and on and on.
>>> Well, your examples are all defining functionality... not libraries...
>>>
>>
>> Right. I agree with Steve here. I think it makes sense to keep the
>> knobs we expect people to twiddle to be for features and not
>> necessarily for libs.
> 
> I really don't understand why having TI-RPC in a library is important here.
> 
> --enable-tirpc is a feature knob.  Forget that it happens to be in a
> library.  Either nfs-utils supports TI-RPC or it supports legacy RPC. 
> The external behavior of nfs-utils changes.
> 
> Legacy RPC is in a library too.  It happens to be in a library that is
> included by default, so configure doesn't have to figure out where RPC
> support is and whether it is installed.
> 
> What's the difference?
Following this theory there should have been an --enable-glibc
which obviously misguided... 

All configuration flags define functionality not supporting parts 
of those functionalities.... 

Lets just have an --enable-ipv6/--disable-ipv6 flag and leave it to
the distros as to how they want to deal with it. 

Now with that said, just because --enable-ipv6 is set, does not have 
to mean *all* IPv6 support is there, especially if its not fully baked.
More times that not, pieces of major new features are released in 
multi updates... Maybe in this first IPv6 release only the supporting 
components are enabled (ala libtirpc). In the next release client 
side rpc.statd is enabled and so on... 

Trickling things in a very slow and control pace makes it much easier 
to manage new functionality... IMHO... and having the big hammer
(ala --disable-ipv6) is a comfortable thing when comes to maintaining  
stability...

steved.

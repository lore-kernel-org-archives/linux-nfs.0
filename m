From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 9 Jun 2009 10:30:01 -0400
Message-ID: <6C2F758F-4274-4952-B139-FA854B7BA48B@oracle.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <4A2CD550.4090609@RedHat.com> <20090608071026.0b57fff8@tupile.poochiereds.net> <4A2D13DF.2040105@RedHat.com> <467512DC-2A83-4432-A29C-1688B021A1F5@oracle.com> <4A2D2862.3090303@RedHat.com> <20090608124140.3fa02688@tlielax.poochiereds.net> <CAFCBD84-FFEB-40FB-9594-40E4E17A8BE3@oracle.com> <4A2E503E.1080809@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:44858 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbZFIOa2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2009 10:30:28 -0400
In-Reply-To: <4A2E503E.1080809-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 9, 2009, at 8:06 AM, Steve Dickson wrote:

> Chuck Lever wrote:
>>>
>>>>>
>>>>>> I guess I just don't see why there has to be two switches for
>>>>>> this feature...
>>>>>
>>>>> Because people seem to want to disable IPv6 support completely  
>>>>> on their
>>>>> systems...  Because there is a striking lack of infrastructure  
>>>>> for IPv6
>>>>> support (including GUIs for configurating ip6tables, lack of IPv6
>>>>> support in NetworkManager, no IPv6 support in tcp_wrappers,
>>>>> inability to
>>>>> disable IPv6 support in the kernel without hacking it out of
>>>>> /etc/modprobe.conf, and so on)...  Because TI-RPC is one level of
>>>>> complexity, and IPv6 adds more complexity...
>>>>>
>>>>> We can probably remove --enable-ipv6, and just stick with
>>>>> --enable-tirpc, which implies IPv6 support, if you prefer that.
>>>> Actually I would like to do just the opposite... remove --enable- 
>>>> tirpc
>>>> and stick with --enable-ipv6...
>>>>
>>>>> But it's a strange argument, when we have --enable-mount,
>>>>> --enable-nfsv4,
>>>>> and on and on.
>>>> Well, your examples are all defining functionality... not  
>>>> libraries...
>>>>
>>>
>>> Right. I agree with Steve here. I think it makes sense to keep the
>>> knobs we expect people to twiddle to be for features and not
>>> necessarily for libs.
>>
>> I really don't understand why having TI-RPC in a library is  
>> important here.
>>
>> --enable-tirpc is a feature knob.  Forget that it happens to be in a
>> library.  Either nfs-utils supports TI-RPC or it supports legacy RPC.
>> The external behavior of nfs-utils changes.
>>
>> Legacy RPC is in a library too.  It happens to be in a library that  
>> is
>> included by default, so configure doesn't have to figure out where  
>> RPC
>> support is and whether it is installed.
>>
>> What's the difference?
> Following this theory there should have been an --enable-glibc
> which obviously misguided...
>
> All configuration flags define functionality not supporting parts
> of those functionalities....

That is exactly what --enable-tirpc does.  The fact that it is in a  
separate library is completely incidental.  Either you get the new  
code and new features (such as support for rpcbind v3/v4 and support  
for IPv6) or you get the legacy behavior.

--enable-tirpc does more than look for a library.  It switches in a  
bunch of new code in nfs-utils itself, and enables new features and  
new behavior.

I honestly don't see a distinction between --enable-gss, which adds  
additional features in nfs-utils, but requires an additional library,  
and --enable-tirpc, which adds additional features, but requires an  
additional library.

> Lets just have an --enable-ipv6/--disable-ipv6 flag and leave it to
> the distros as to how they want to deal with it.

We already have a run-time switch for IPv6 support: It's /etc/ 
netconfig.  Of course, that switch is entirely ignored if TI-RPC  
support is not built in.  The point is we don't need the configure  
switch at all: if --disable-tirpc is specified, then no IPv6 support  
is available.  if --enable-tirpc is specified, then IPv6 support is  
possible if there are visible inet6 transports in /etc/netconfig.

> Now with that said, just because --enable-ipv6 is set, does not have
> to mean *all* IPv6 support is there, especially if its not fully  
> baked.
> More times that not, pieces of major new features are released in
> multi updates... Maybe in this first IPv6 release only the supporting
> components are enabled (ala libtirpc). In the next release client
> side rpc.statd is enabled and so on...
>
> Trickling things in a very slow and control pace makes it much easier
> to manage new functionality... IMHO... and having the big hammer
> (ala --disable-ipv6) is a comfortable thing when comes to maintaining
> stability...
>
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




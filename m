From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Tue, 28 Apr 2009 13:50:11 -0500
Message-ID: <0122F800A3B64C449565A9E8C297701005E6DE1A@hoexmb9.conoco.net>
References: <200904271903.36379.bircoph@gmail.com> <1810FE6E-D2AF-4ED3-BE34-F6117A8D9B46@oracle.com> <200904280444.00206.bircoph@gmail.com> <E3A82BE4-E39C-4E4E-9CBA-4CD182E73CBB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Chuck Lever" <chuck.lever@oracle.com>,
	"Andrew Savchenko" <bircoph@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman1.ppco.com ([138.32.41.4]:52527 "EHLO mailman1.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122AbZD1TGY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 15:06:24 -0400
Received: from bvlextrd1.conoco.net (bvlextrd1.conoco.net [138.32.41.12])
	by mailman1.ppco.com (Switch-3.3.0/Switch-3.2.7) with ESMTP id n3SIpkdN032478
	for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2009 13:51:47 -0500
In-Reply-To: <E3A82BE4-E39C-4E4E-9CBA-4CD182E73CBB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I, too, have seen this just this last weekend.  I have a vanilla
2.6.29.1 kernel on Fedora 10, and I compiled it with IPV4 and IPV6, plus
NFSv3 and NFSv4, plus the new rpcbind 4 support.  With IPV6 blacklisted,
NFSv3 would not mount.  It had the same error message as Andrew
"mount.nfs: Address family not supported by protocol".  Once I
whitelisted IPV6, NFS would mount.  Unfortunately, this is not a good
situation for me because IPV6 plays havoc with my network for some
reason (darn cheap Linksys router probably).

I went back and turned off the RPCBind v4 and recompiled the NFS
modules, and now I can blacklist IPV6 and my NFSv3 works fine.  It is a
strange problem.  My server, a Fedora 10 box, showed that it was
authenticating the mount request fine...

Norman Weathers 

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Tuesday, April 28, 2009 11:17 AM
> To: Andrew Savchenko
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
> 
> On Apr 27, 2009, at 8:43 PM, Andrew Savchenko wrote:
> > Hello,
> >
> > On Monday 27 April 2009, Chuck Lever wrote:
> >> On Apr 27, 2009, at 11:03 AM, Andrew Savchenko wrote:
> >>> Hello,
> >>>
> >>> I have ipv6 support as a module (it may be needed in the
> >>> recent future), but currently I want ipv6 to be disabled on my
> >>> system, so I blacklisted this module. And here problems
> >>> begin...
> >>>
> >>> NFSv3 works flawlessly:
> >>> # mount 172.19.0.1:/home/ftp /mnt/nfs/
> >>>
> >>> but NFSv4 fails:
> >>> # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
> >>> mount.nfs4: Cannot allocate memory
> >>>
> >>> After modprobe ipv6 it works:
> >>> # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
> >>>
> >>> I recompiled nfs-utils without ipv6 support, but this doesn't
> >>> help.
> >>>
> >>> Here is my /etc/exports:
> >>> /home/ftp 172.16.0.0/12
> >>> (ro,async,crossmnt,no_subtree_check,fsid=0,all_squash) \
> >>>       127.0.0.1/32
> >>> (ro,async,crossmnt,no_subtree_check,fsid=0,all_squash)
> >>>
> >>> I use nfs-utils-1.1.5, I tested this on both vanilla linux
> >>> kernels 2.6.28.7 and 2.6.28.9.
> >>
> >> Have you tried this with 2.6.29?
> >
> > I just tried with vanilla 2.6.29.1. Things became even worse. Now
> > not only NFSv4 fails to mount as usual, but NFSv3 fails too:
> >
> > # mount 172.19.0.1:/home/ftp /mnt/orionis
> > mount.nfs: Address family not supported by protocol
> >
> > And following error appears in kernel log multiple times:
> > RPC: failed to contact local rpcbind server (errno 5).
> >
> > I attached strace -f for both mount attempts. The problem is in
> > mount() syscall in both cases, thus somewhere inside the kernel...
> >
> > With ipv6 module loaded all works fine.
> 
> Right, this isn't an nfs-utils problem, it's an issue in the kernel  
> (so the strace isn't terribly informative).  2.6.29 is supposed to  
> have addressed this problem, but maybe you are hitting a new 
> way that  
> not having ipv6.ko loaded is buggering us.
> 
> If you're building these kernels yourself, why not disable 
> CONFIG_IPV6?
> 
> >> You can also try building 2.6.28 with CONFIG_SUNRPC_REGISTER_V4
> >> disabled.
> >
> > With this option disabled errno 5 (see above) disappeared from
> > logs, but mount fails with the same errors. Yet again, with ipv6
> > module loaded it works ok.
> 
> I can't reproduce here on 2.6.30-rc2, so it may be just an 
> issue with  
> 2.6.29.  You can enable debug printks to see what the kernel 
> thinks is  
> going on.  Try this as root:
> 
>    # rpcdebug -m nfs -s mount
>    # mount ....
>    # rpcdebug -m nfs -c
> 
> Then look in your kernel log.  "rpcdebug -vh" will list the full set  
> of flags you can enable.
> 
> Since rpcbind also seems to be an issue, you can try this also:
> 
>    # rpcdebug -m rpc -s bind
>    # mount ....
>    # rpcdebug -m rpc -c
> 
> What type of server are you attempting to mount?  Linux?  Solaris?
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

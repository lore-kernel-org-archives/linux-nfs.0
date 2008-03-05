From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] (no subject)
Date: Wed, 05 Mar 2008 08:49:26 -0500
Message-ID: <EXNANE01NXRPmcarcR400000026@exnane01.hq.netapp.com>
References: <BLU125-W88EBFC80912D4F211F072D3110@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: =?gb2312?B?yre+/NPC?= <shi.jun.yong@hotmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45280 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbYCENuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 08:50:16 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JWu0Z-0000cX-Ia
	for linux-nfs@vger.kernel.org; Thu, 06 Mar 2008 00:50:11 +1100
In-Reply-To: <BLU125-W88EBFC80912D4F211F072D3110-MsuGFMq8XAE@public.gmane.org>
References: <BLU125-W88EBFC80912D4F211F072D3110-MsuGFMq8XAE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 08:49 PM 3/4/2008, =?gb2312?B?yre+/NPC?= wrote:
>Dear friend,
>   I appreciate you read my letter.
>   Recently, I use nfs-utils-1.1.0-rc1 on S3C2510 embeded board. The operation system is arm linux which is developed by HuaHeng Company of China. I compile the software package of nfs-utils-1.1.0-rc1 on RedHat Linux and use arm-unknown-linux-gcc compilor. The configuring command is:
>   ./configure --disable-gss --disable-uuid --disable-nfsv4
>   The computer remind me that the libwrap file is of shortcome. How can I do?

It's looking for the "tcpwrappers" library. Since you're building for an embedded
system, I would recommend simply turning off that feature, which you can do
with by adding the following flag:

./configure --disable-gss --disable-uuid --disable-nfsv4 --without-tcp-wrappers

The resulting binaries should run fine on arm-linux, as long as you're using the
appropriate toolset to build for the target.

Is there some reason you have chosen nfs-utils 1.1.0-rc1? The current version
is 1.1.1:
        <http://sourceforge.net/project/showfiles.php?group_id=14&package_id=174&release_id=548083>

Tom.

>   I want to build a nfs server using S3C2510 embeded board and use nfs-utils-1.1.0-1.1.0-rc1 to manage nfs server. How can I reaolve the above problem. If I successfully compile thd nfs-utils-1.1.0-rc1, can I run the software on arm linux? The kernel of arm linux and the library of arm linux are needed to be modified?
>   I am glad to receive your letter.
> 
>                                                    A friend of China, Shi-Junyong
>                                                               3/5,2008


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


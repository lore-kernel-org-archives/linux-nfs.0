Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:47936 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab0DVBUJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 21:20:09 -0400
Message-ID: <4BCFA444.3060003@gmail.com>
Date: Wed, 21 Apr 2010 20:20:04 -0500
From: Roger Heflin <rogerheflin@gmail.com>
To: Vlad Glagolev <stealth@sourcemage.org>
CC: Steve Cousins <steve.cousins@maine.edu>, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org
Subject: Re: NFS and /dev/mdXpY
References: <20100417195747.5fae8834.stealth@sourcemage.org>	<4BCF2A2C.7070407@maine.edu>	<20100421204819.b86ee3f7.stealth@sourcemage.org>	<q2zd3da20d01004211009jccd81479v83e2ef4b6d5db7bf@mail.gmail.com>	<20100421213201.67a4a7a2.stealth@sourcemage.org> <20100421222612.7aa4f21a.stealth@sourcemage.org>
In-Reply-To: <20100421222612.7aa4f21a.stealth@sourcemage.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Vlad Glagolev wrote:
> Hmm, more testing.. It works only with tiny files flawlessly on OpenBSD (client).
> 
> If a filesize is around 50 mibs, then it just freezes and eats cpu with nfsrcvl call.
> 
> On Linux I don't see such problem. Even big files are transfered with good enough speed.
> 

I think that is a second problem.   There are simple ways to screw up 
the fsid's and produce stale fs warnings...so I was guessing it might 
be a slightly different variation of the one I had seen before were we 
were getting through some series of commands different exported fs 
with the same fsid and the client machine basically had the fs 
switched out from under it...

You might try different nfsvers(may work, but ver 2 has some issues 
displaying the proper sizes on >2tb fs, and has 1-2tb file limits--I 
believe) on the mounts on bsd, and or different wsize/rsize(unlikely 
to help) and such...but I am not sure it will necessarily matter, but 
one may cause less issues from with one set of options vs another as 
each is likely a fairly different code path, and the same with trying 
the proto tcp vs udp changes quite a bit of code out...

You can on most oses check what options were actually accepted on the 
mount on linux it is a cat /proc/mounts the mount command may do it on 
bsd...but that will tell you if it accepted the specified options or 
ignored them.

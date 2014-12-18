Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:46076 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaLRPnP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 10:43:15 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Y1dEG-0000FV-Iv
	for linux-nfs@vger.kernel.org; Thu, 18 Dec 2014 16:43:04 +0100
Received: from p4ff58315.dip0.t-ipconnect.de ([79.245.131.21])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 16:43:04 +0100
Received: from holger.hoffstaette by p4ff58315.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 16:43:04 +0100
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: 3.18.1: broken directory with one file too many
Date: Thu, 18 Dec 2014 15:42:53 +0000 (UTC)
Message-ID: <pan.2014.12.18.15.42.53@googlemail.com>
References: <pan.2014.12.16.22.19.18@googlemail.com>
	<20141217212159.GA11517@fieldses.org> <5492C710.20104@googlemail.com>
	<20141218144856.GA18179@fieldses.org>
	<alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
	<20141218151914.GB18179@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Dec 2014 10:19:14 -0500, J. Bruce Fields wrote:

> On Thu, Dec 18, 2014 at 09:58:06AM -0500, Benjamin Coddington wrote:
>> Frame 36 of nfs-client.pcap has this interesting string:
>> 
>> 0ff0  00 01 3b f6 fb b6 26 16 8f 7c 00 00 00 41 62 74  
>> ..;...&..|...Abt 1000  72 66 73 2d 32 30 00 00 00 00 00 00 00 00 30 36 
>>  rfs-20........06 1010  2d 66 69 78 2d 64 65 61 64 6c 6f 63 6b 2d 77 68
>>   -fix-deadlock-wh 1020  65 6e 2d 6d 6f 75 6e 74 69 6e 67 2d 61 2d 64
>> 65   en-mounting-a-de 1030  67 72 61 64 65 64 2d 66 73 2e 70 61 74 63
>> 68 00   graded-fs.patch.
> 
> Yes, that looks like the server messing up the encoding of the reply.
> 
> Holger, what's the difference between nfs-client.pcap and
> nfs-server.pcap?

One is the client, one is the server :-)

No, really. Both 3.18.1, 64it, same userland/compiler/etc. and even same 
CFLAGS for both kernel and userland. I built tcpdump on both (from 
packages) and ran them back to back literally 10 seconds apart.

What "encoding" are we talking about here? The NFS RPC encoding?
(everything I know & remember about NFS is 15+ years old..)

thanks,
Holger


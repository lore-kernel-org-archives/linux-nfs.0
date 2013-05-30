Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f41.google.com ([74.125.82.41]:52514 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030539Ab3E3LE2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 07:04:28 -0400
Received: by mail-wg0-f41.google.com with SMTP id k13so4964120wgh.4
        for <linux-nfs@vger.kernel.org>; Thu, 30 May 2013 04:04:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E626E85E-BC60-4FBA-BF02-536508991C65@oracle.com>
References: <1480713067.24683.1369783846612.JavaMail.root@erie.cs.uoguelph.ca> <E626E85E-BC60-4FBA-BF02-536508991C65@oracle.com>
From: Bram Vandoren <brambi@gmail.com>
Date: Thu, 30 May 2013 13:04:06 +0200
Message-ID: <CACQjR_DV_2QFd0O1e6R6M34_R87+Bn+zvn3w_BkhS9YESNVUzg@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> It's not typical for a client with an active workload to wait 4400 seconds to send a fresh SYN.  Bram, can you shed any light on this?

The server was down for ~4400 seconds (I started the capture before
the maintanance period). I captured the packets using a switch mirror
port (it's possible some packets are lost during capture). After a
while an arp timeout occurs and we don't capture the SYNs from the
client any more (I doubt the client sends the SYN because it doesn't
know where to send it).

If it helps, I can filter extra information from the big pcap file
(~20G) (eg capture from other clients or from the same client just
before the server reboot).

Thanks,
Bram.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:52980 "EHLO
	esa-annu.net.uoguelph.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751765Ab3E3LzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 07:55:21 -0400
Date: Thu, 30 May 2013 07:55:19 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Bram Vandoren <brambi@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Message-ID: <1562611687.61201.1369914919633.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <CACQjR_DV_2QFd0O1e6R6M34_R87+Bn+zvn3w_BkhS9YESNVUzg@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bram Vandoren wrote:
> > It's not typical for a client with an active workload to wait 4400
> > seconds to send a fresh SYN. Bram, can you shed any light on this?
> 
> The server was down for ~4400 seconds (I started the capture before
> the maintanance period). I captured the packets using a switch mirror
> port (it's possible some packets are lost during capture). After a
> while an arp timeout occurs and we don't capture the SYNs from the
> client any more (I doubt the client sends the SYN because it doesn't
> know where to send it).
> 
> If it helps, I can filter extra information from the big pcap file
> (~20G) (eg capture from other clients or from the same client just
> before the server reboot).
> 
> Thanks,
> Bram.
Did both the client and server have the same IP addresses before the
reboot?

If not, the Linux client's nfs_client_id4.id SetClientID argument
will be different (it has the client/side IP# in it). nfs_client_id4.id
isn't supposed to change for a given client when it is rebooted.
That will make the FreeBSD NFSv4 server see "new client" (which is not in the
stablerestart file used to avoid certain reboot edge conditions) and
will not give it a grace period. 
This is the only explanation I can think of for the NFS4ERR_NO_GRACE
reply shortly after the reboot.

I'd guess the RSTs are because the nfsd has terminated (nothing on
port# 2049) just before the system was shut down, so I suspect the
RSTs are not an issue? (I have assumed the packet trace started after
the server rebooted.)

rick

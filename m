Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:34677 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752917AbeF2PEq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2018 11:04:46 -0400
Received: by mail-it0-f54.google.com with SMTP id y127-v6so2522475itd.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2018 08:04:46 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: RDMA connection closed and not re-opened
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
Date: Fri, 29 Jun 2018 11:04:43 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
To: admin@genome.arizona.edu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chandler-


> On Jun 28, 2018, at 8:23 PM, admin@genome.arizona.edu wrote:
>=20
> Dear Chuck et. al.,
>=20
> Sorry for my late reply.  I have since lost the previous messages in =
my news client and gmane isn't very reliable anymore.  I am replying to =
the message-id A9E63254-22F5-48A7-85C2-8016D85CD192 [1] which was in =
reference to my original posts [2][3] (links in footer).
>=20
> We keep having this problem and having to reset servers and losing =
work.  The latest incident involved 7 out of 9 of our NFS clients.  I've =
attached the latest messages from these clients (n001.txt through =
n007.txt) as well as the messages from the server.
>=20
> Here is a short summary in chronological order: I first notice a =
message on our server at Jun 27 19:09:03 in reference to Ganglia not =
being able to reach one of the data sources.  Not sure if it is related =
but the message seems to only appear when there are these problems with =
the NFS... the next message doesn't happen until Jun 27 20:01:55.
>=20
> On the clients, the first errors happen on n005,
> Jun 27 20:04:07 n005 kernel: RPC:       rpcrdma_sendcq_process_wc: =
frmr ffff88204ea3b840 (stale): WR flushed
>=20
> there are similar messages on n007 and n003 which happen at 20:04:09 =
and 20:04:17.  However I don't see these "WR flushed" messages on the =
other nodes.  These are accompanied by the INFO messages that our =
application (daligner) is being blocked as well as the "rpcrdma: =
connection to 10.10.11.10:20049 closed (-103)" error.  After that the =
nodes become unresponsive to SSH, although Ganglia seems to still be =
able to collect some information from them as I can see the load graphs =
continually increasing.

These are informational messages that are typical of network
problems or maybe the server has failed or is overloaded. I'm
especially inclined to think this is not a client issue because it
happens on multiple clients at around the same time.

These appear to be typical of all the clients:

Jun 27 20:07:07 n005 kernel: nfs: server 10.10.11.10 not responding, =
still trying
Jun 27 20:08:34 n005 kernel: rpcrdma: connection to 10.10.11.10:20049 on =
mlx4_0, memreg 5 slots 32 ird 16
Jun 27 20:08:35 n005 kernel: nfs: server 10.10.11.10 OK
Jun 27 20:08:35 n005 kernel: nfs: server 10.10.11.10 not responding, =
still trying
Jun 27 20:08:35 n005 kernel: nfs: server 10.10.11.10 OK
Jun 27 20:13:59 n005 kernel: RPC:       rpcrdma_sendcq_process_wc: frmr =
ffff88204f86b380 (stale): WR flushed
Jun 27 20:13:59 n005 kernel: RPC:       rpcrdma_sendcq_process_wc: frmr =
ffff88204eea9180 (stale): WR flushed
Jun 27 20:13:59 n005 kernel: RPC:       rpcrdma_sendcq_process_wc: frmr =
ffff88204e743f80 (stale): WR flushed
Jun 27 20:15:43 n005 kernel: rpcrdma: connection to 10.10.11.10:20049 on =
mlx4_0, memreg 5 slots 32 ird 16
Jun 27 20:32:08 n005 kernel: rpcrdma: connection to 10.10.11.10:20049 =
closed (-103)

The "closed" message appears only in some client logs.

On the server:

Jun 27 20:08:34 pac kernel: svcrdma: failed to send reply chunks, rc=3D-5
Jun 27 20:08:34 pac kernel: nfsd: peername failed (err 107)!
Jun 27 20:08:34 pac kernel: nfsd: peername failed (err 107)!
Jun 27 20:08:35 pac kernel: svcrdma: failed to send reply chunks, rc=3D-5

This is suspicious. I don't have access to the CentOS 6.9 source
code, but it could mean that the server logic that transmits reply
chunks is broken, and the client is requesting an operation that
has to use reply chunks. That would cause a deadlock on that
connection because the client's recourse is to send that operation
again and again, but the server would repeatedly fail to reply.


> We haven't had this problem until recently.  I upgraded our cluster to =
add two additional nodes (n008 and n009, which have problems too and =
have to be rebooted) and we also added more storage to the server.  The =
jobs are submitted to the cluster via Sun Grid Engine, and in total =
there are about 61 jobs (daligner) that may start at once and open =
connections to the NFS server... is it too much work for NFS to handle?
>=20
> Yes both clients and servers have CentOS 6.9.  Is there a way to =
report this to Red Hat?  Otherwise i'm not sure of a way to report this =
to the "Linux distributor".

I don't know how to contact CentOS support, but that would be the
first step here to do the basic troubleshooting steps with people
who are familiar with that code base and the tools that are available
in that distribution.

Perhaps a RH staffer on this list could provide some guidance?


> The machines are not completely updated and there appears to be a new =
kernel (2.6.32.696.30.1.el6) available as well as new nfs-utils =
(1:1.2.3-75.el6_9).  So not sure if updating those may help...

If there are no other constraints on your NFS server's kernel /
distribution, I recommend upgrading it to a recent update of CentOS
7 (not simply a newer CentOS 6 release).

IMO nfs-utils is not involved in these issues.


> If you do not see any solution to this old implementation then would =
you perhaps suggest I manually install the latest stable version of NFS =
on the clients and server?  In that case please let me know of any =
relevant configure flags I might need to use if you can think of any off =
the top of your head.

The NFS implementation is integrated into the Linux kernel, so it's
not a simple matter of "installing the latest stable version of NFS".


> Many Thanks,
> Chandler / Systems Administrator
> Arizona Genomics Institute
> www.genome.arizona.edu
>=20
> --
> 1. https://marc.info/?l=3Dlinux-nfs&m=3D152545311928035&w=3D2
> 2. https://marc.info/?l=3Dlinux-nfs&m=3D152538002122612&w=3D2
> 3. https://marc.info/?l=3Dlinux-nfs&m=3D152538859227047&w=3D2
>=20
>=20
> =
<n001.txt><n002.txt><n003.txt><n004.txt><n005.txt><n006.txt><n007.txt><ser=
ver.txt>

--
Chuck Lever
chucklever@gmail.com




Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44130 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab1LVSbD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2011 13:31:03 -0500
Received: by vcbfk14 with SMTP id fk14so6781575vcb.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2011 10:31:02 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 22 Dec 2011 13:31:02 -0500
Message-ID: <CAOO4vO7nfROsXh6r6NTPF9MtXXNH0LawT=TfxXUea=wae3tYxw@mail.gmail.com>
Subject: NFSv4 empty RPC thrashing?
From: Paul Anderson <pha@umich.edu>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Issue: extremely high rate packets like so (tcpdump):

16:31:09.308678 IP (tos 0x0, ttl 64, id 41517, offset 0, flags [DF],
proto TCP (6), length 144)
    r20.xxx.edu.1362383749 > nfsb.xxx.edu.nfs: 88 null
16:31:09.308895 IP (tos 0x0, ttl 64, id 22578, offset 0, flags [DF],
proto TCP (6), length 100)
    nfsb.xxx.edu.nfs > r20.xxx.edu.1362383749: reply ok 44 null
16:31:09.308926 IP (tos 0x0, ttl 64, id 41518, offset 0, flags [DF],
proto TCP (6), length 192)
    r20.xxx.edu.1379160965 > nfsb.xxx.edu.nfs: 136 null

All linux kernels are from kernel.org, version 2.6.38.5 with the
addition of Mosix.  All userland is Ubuntu 10.04LTS.

Scenario: the compute cluster is composed of 50-60 compute nodes, and
10 or so head nodes that act as compute/login and high rate NFS
serving, for the purpose of largely sequential processing of high
volume genetic sequencing data (one recent job was 50-70TiBytes in, 50
TiBytes out).  We see this problem regularly (two servers are
currently being hit this way right now), and is apparently cleared
only on reboot of the server.

Something in our use of the cluster appears to be triggering what
looks like a race condition in the NFSv4 client/server communications.
 This issue prevents us from using NFS reliably in our cluster.
Although we do very high I/O at times, this alone does not appear to
be the trigger.  It is possibly a related to a problem of having SLURM
starting 200-300 jobs at once, where each job hits a common NFS
fileserver for the program binaries, for example.  In our cluster
testing, this appears to reliably cause about half the jobs to fail
while loading the program itself - they hang in D state indefinitely,
but are killable.

Looking at dozens of clients, we can do tcpdump, and see messages
similar to the above being sent at a high rate from the gigabit
connected compute nodes - the main indication being a context switch
rate of 20-30K per second.  The 10 gigabit connected server is
functioning, but seeing context switch rates of 200-300K per second -
an exceptional rate that appears to slow down NFS services for all
other users.  I have not done any extensive packet capture to
determine actual traffic rates, but am pretty sure it is limited by
wire speed and CPU.

The client nodes in this scenario are not actively being used - some
show zero processes in D state, others show dozens of jobs stuck in D
state (these jobs are unkillable) - the NFSv4 server shows nfsd jobs
running flat out.

Mount commands look like this:
for h in $servers do ;
    mount -t nfs4 -o rw,soft,intr,nodev,nosuid,async ${h}:/ /net/$h
done

The NFSv4 servers all start using stock Ubuntu 10.04 setup - no tuning
has been done.

We can trivially get packet captures with more packets, but they are
all similar - 15-20 client nodes all pounding one NFS server node.

Any guesses as to what we can try?

Thanks,

Paul Anderson

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.citrix.com ([66.165.176.89]:12983 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab1KISiH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 13:38:07 -0500
Message-ID: <4EBAC88D.40902@citrix.com>
Date: Wed, 9 Nov 2011 18:38:05 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: linux-nfs <linux-nfs@vger.kernel.org>
Subject: unexpected NFS timeouts, related to sync/async soft mounts over TCP
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I am debugging an issue for a customer whereby an NFS mount undergoes an
unexpected timeout and throws an EIO.

Using synchronous mounts results in no problems whatsoever, whereas
using asynchronous mounts causes the problem to occur.

The problem exists only on 10GiB networks: I can't repro on slower
networks at all, even if it is the same 10GiB network link limited to
1GiB.  It reproduces on multiple versions of XenServer (both Xen 3 and
Xen 4) with a 2.6.32 based dom0 kernel multiple different 10GiB network
cards (be2net and bnx2x specifically tested).  It also reproduces
against multiple different netapp servers running different firmware
versions.  It also appears to reproduces with NFSv3 and NFSv4, although
the customer setup uses NFSv3

The difference between mount commands are "noac" for the synchronous
case as opposed to "actimeo=0" for the asynchronous case.

The /proc/mounts entry for async is:
10.70.148.3:/vol/camb5e3b16tmp/82ab4a02-c10f-144a-e8c2-2ae04f213b2a
/var/run/sr-mount/82ab4a02-c10f-144a-e8c2-2ae04f213b2a nfs
rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,soft,proto=tcp,port=65535,timeo=133,retrans=0,sec=sys,mountport=65535,addr=10.70.148.3
0 0

while the entry for sync is:
10.70.148.3:/vol/camb5e3b15tmp/bc11aad3-b345-519f-1661-50e16bed6cdb
/var/run/sr-mount/bc11aad3-b345-519f-1661-50e16bed6cdb nfs
rw,sync,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,soft,proto=tcp,port=65535,timeo=133,retrans=0,sec=sys,mountport=65535,addr=10.70.148.3
0 0

The bug itself feels very like a timing issue to me.  It becomes
substantially easier to reproduce if the kernel has a high workload:
Different options involve disabling things like TSO offload on the
network card or dd'ing from /dev/urandom to /tmp, but the problem cant
be reproduced occasionally without any artificial extra workload.  The
problem itself can be reprodued with a simple dd from /dev/zero onto the
nfs mount, which proceeds to transfer at ~220MBps until the EIO is hit.

I have analyzed the TCP stream using TCPdump and Wireshark.  Everything
appears fine, with no NFS errors at all.  However, the client sticks a
TCP FIN in the final continuation of one of its 64k block writes, in the
middle of writing the file.

The server ACKs the outstanding packets, and sends a Write Reply
(without error), but does not send its own FIN.  Then, 15 seconds later,
the client sends a TCP RST, and throws an EIO back to userspace.

I am aware that sending a RST after 15 seconds is expected behavior
following changeset 7d1e8255cf959fba7ee2317550dfde39f0b936ae, in an
attempt to prevent deadlocks for a half closed TCP connection.  I have
searched through the commit log all the way to tip, but can not find a
commit making any reference to problems similar to this.

What I am struggling to work out is why the client is sending a FIN in
the middle of an otherwise fine and error-free NFS stream.  using
"rpcdebug -m rpc -s trans" only says "disconnected" without giving a
reason for disconnecting.

Is there a different debug flag I can use to find out why NFS thinks it
needs to disconnect, or does anyone have any suggestions as to where I
should start debugging the code?  I suspect the problem is in the sunrpc
subsystem but I am not very familiar with code this high level in the
kernel.

Any help greatly appreciated

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.enst.fr ([137.194.2.135]:48048 "EHLO smtp.enst.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753801AbaBRQjV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 11:39:21 -0500
From: Manuel Sabban <manuel.sabban@telecom-paristech.fr>
To: linux-nfs@vger.kernel.org
Subject: multiple NFS4ERR_STALE_STATEID on 3.12 (wheezy)
Date: Tue, 18 Feb 2014 17:30:44 +0100
Message-ID: <87bny4758r.fsf@leto.enst.fr>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We have approximatively one hundred desktop computers with 3.12.6 kernel
and debian wheezy system. NFS is used for homes. Mount options are
"rw,nosuid,nodev,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,
soft,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,local_lock=none".

The NFS server we use is the ZFS appliance from Oracle
(http://www.oracle.com/us/products/servers-storage/storage/nas/zfs7420/overview/index.html). The
server does some short-to-very-long pauses (from several minutes to
several hours, because of a known bug acknowledged by oracle in our
configuration) and we suspect that this behaviour trigger the behaviour
described below.

What we understand is that when the server is back online, the client
try to write something on the NFS and the server throw a STALE_STATEID
error. And, then the client try again, with the same result, and try
again, and again... This is happening at the rate of 3300 packets per
second, on the example below.

At this point, the client get hung, and the enabled traces
showed a full trace file of
kworker/1:0-11993 [001] .... 1171115.807948: nfs4_read: error=-10023 (STALE_STATEID) fileid=00:1f:283 fhandle=0xb1863420 offset=0 count=12288
kworker/1:0-11993 [001] .... 1171115.808543: nfs4_read: error=-10023 (STALE_STATEID) fileid=00:1f:283 fhandle=0xb1863420 offset=0 count=12288
kworker/1:0-11993 [001] .... 1171115.809111: nfs4_read: error=-10023 (STALE_STATEID) fileid=00:1f:283 fhandle=0xb1863420 offset=0 count=12288

The network dump showed similar things with the NFS4ERR_STALE_STATEID
error. Then, the computer has to be hard rebooted.

How can this behaviour be avoided ?

You will find debugging traces and network dump at
http://perso.telecom-paristech.fr/~sabban/debugNFS/tsilinuxb96

Thanks for your help
Regards,
Manuel Sabban

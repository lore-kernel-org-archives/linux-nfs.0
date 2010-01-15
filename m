From: "Becker Vosloo" <Becker.Vosloo-WpcINk3L64l+l3BRcVcdTQ@public.gmane.org>
Subject: NFS V3 Problems
Date: Fri, 15 Jan 2010 10:17:52 +0200
Message-ID: <1266C849500FBB49BA6B7927D692F26B06DC439F@MX-EVS-1.za.saabgroup.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.za.saabgroup.com ([196.11.195.164]:12123 "EHLO
	zahfmm01.za.saabgroup.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751937Ab0AOIR6 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jan 2010 03:17:58 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good Day,


I am using a Linux NFS client to mount to a dedicate NFS server
implemented using Wind River VxWorks 6.5.

 

The VxWorks server has the ability to support NFS using either UDP or
TCP. With configuration files I can disable the NFS-UDP services on my
VxWorks server, as well as disable the NFS-TCP services.

 

The following were observed: 

1. With my VxWorks server configured to only support NFS-UDP services, I
mount (proto=udp) from a Linux client, all works well, very responsive.

2. With my VxWorks server configured to only support NFS-TCP services, I
mount (proto=tcp ) from a Linux client, all works well, very responsive.

3. With my VxWorks server configured to support both NFS-TCP and NFS-UDP
services, I mount (proto=tcp) from a Linux client, all works well.

4. With my VxWorks server configured to support both NFS-TCP and NFS-UDP
services, I mount (proto=udp) from a Linux client, then things become
very slow when performing file system type commands from the client. For
example, performing a command ls /mnt/01, takes approximately 45 seconds
to complete, where in the other cases this command took less than 200ms
to complete. Using wireShark to record the network traffic, I noticed,
that in the latter case (4), the Linux client issue a huge amount of
GETATTR requests, after the READDIR requests. These extra GETATTR seems
to be the problem, as they do not appear in cases 1, 2 and 3 above. Any
idea what I can do to solve this? 




P.S.  Unfortunately I have to cater for the case, due to legacy, to
handle clients across UDP and TCP. Transferring a file from the mounted
volume while connected as described in case 4 is fine. The data
throughput is as expected and correlates to that measured in steps 1, 2
and 3. It is only the mount, unmount and file system related RPCs that
is slow.

 

Becker Vosloo

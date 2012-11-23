Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39821 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab2KWLCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Nov 2012 06:02:30 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so6459469pbc.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Nov 2012 03:02:29 -0800 (PST)
Message-ID: <50AF57A3.3090000@gmail.com>
Date: Fri, 23 Nov 2012 16:31:55 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Slow NFS loop performance.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Humm... The last thing I expected was no response even in the mailing list.

So I'm filing a bug on this.

On Oct 23, 2012 2:19 PM, "dE ." <de.techno@gmail.com> wrote:
 > Hi!
 >
 > Great job with NFS server, it surely is fast, but not on loop devices.
 >
 > If I loop mount a file and share the mount point over NFS3 or NFS4, the
 > write performance of the client on the loop mounted share is pretty bad.
 >
 > On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps
 > speeds, whereas on the loop mounted device, I get at best 6MBps.
 >
 > Any ideas why?
 >
 > My server configuration (NFS4) --
 > anonuid=1000,anongid=1000,**secure,no_subtree_check,rw,**fsid=0,crossmnt
 >
 > My client mount options --
 > rsize=1048576,wsize=1048576,**async,hard,timeo=60,retrans=2,**
 > actimeo=900,retry=2,**lookupcache=pos,nfsvers=4,**
 > nolock,intr,noacl,rdirplus
 >


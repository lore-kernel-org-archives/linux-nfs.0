Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:37287 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238Ab2JWIta (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 04:49:30 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so1824270dak.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2012 01:49:30 -0700 (PDT)
Message-ID: <50866815.30103@gmail.com>
Date: Tue, 23 Oct 2012 15:19:09 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: slow loop performance.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

Great job with NFS server, it surely is fast, but not on loop devices.

If I loop mount a file and share the mount point over NFS3 or NFS4, the 
write performance of the client on the loop mounted share is pretty bad.

On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps 
speeds, whereas on the loop mounted device, I get at best 6MBps.

Any ideas why?

My server configuration (NFS4) --
anonuid=1000,anongid=1000,secure,no_subtree_check,rw,fsid=0,crossmnt

My client mount options --
rsize=1048576,wsize=1048576,async,hard,timeo=60,retrans=2,actimeo=900,retry=2,lookupcache=pos,nfsvers=4,nolock,intr,noacl,rdirplus

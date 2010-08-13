Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39215 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab0HMUyz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 16:54:55 -0400
Received: by wyb32 with SMTP id 32so3054946wyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 13:54:54 -0700 (PDT)
From: Rahul Nabar <rpnabar@gmail.com>
Date: Fri, 13 Aug 2010 15:54:34 -0500
Message-ID: <AANLkTik_gAeTWhD_=zSUrqh2eYir=q4bK4cJ6UdGQ11M@mail.gmail.com>
Subject: NFS and file locking for use with sqllite
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I came across a snippet in the sqlite FAQ that warns against using
some network file-systems due to file locking bugs. In the past I've
had excellent experiences using NFS+Linux (CentOS) so was wondering if
people had comments if or not this (fairly vague) warning might apply
to NFS or not at all?

>From the sqlite FAQ:

.........the file locking logic of many network filesystems
implementation contains bugs (on both Unix and Windows). If file
locking does not work like it should, it might be possible for two or
more client programs to modify the same part of the same database at
the same time, resulting in database corruption..........

Does file-locking in NFS work "as it should". Is this dependent on the
particular options I pass to the NFS mount? e.g. I usually use hard
mounts with the intr option.
A snippet from my fstab:

eustorage:/opt /opt nfs
rw,nodev,noatime,nfsvers=3,timeo=110,retrans=50,hard,intr,proto=udp,rsize=32768,wsize=32768
0 0

If I desired the ideal file-locking properties should I be modifying /
adding any particular option?

-- 
Rahul

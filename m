Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f41.google.com ([209.85.128.41]:49144 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaAPLbz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 06:31:55 -0500
Received: by mail-qe0-f41.google.com with SMTP id i11so2384169qej.14
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 03:31:54 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 16 Jan 2014 17:01:54 +0530
Message-ID: <CAPQuqip0WvBLNPN+7ahMrzPA=GdUroQXWH9vo_SrXPJ70mHkEg@mail.gmail.com>
Subject: nfs attribute cache question
From: ranjith ruban <ranjithruban@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello

I had set nfs mount actiomeo option for 300 seconds for a share. The
client is an openvz server with container filesystems in nfs . Server
is netapp.

While going through the tcpdump i see below

125     2014-01-15 16:06:01.770522      10.X.0.X    10.X.0.X     NFS
  190     V3 GETATTR Call (Reply In 126), FH: 0x496fe5c5
126     2014-01-15 16:06:01.770637      10.X.0.X    10.X.0.X    NFS
 182     V3 GETATTR Reply (Call In 125)  Regular File mode: 0644 uid:
0 gid: 0

this call returns file id 2691421

 find /vz/private/X/ -inum 2691421 -exec ls -l {} \;
 -rw-r--r-- 1 root root 1128 Jul 14  2011 /vz/private/X/fs/root/etc/passwd

 Now after a minute i do see the same call again to same file handle.

294   2014-01-15 16:07:01.771152      10.X.0.X    10.X.0.X     NFS
190     V3 GETATTR Call (Reply In 295), FH: 0x496fe5c5
295   2014-01-15 16:07:01.771261      10.X.0.X     10.X.0.X   NFS
182     V3 GETATTR Reply (Call In 294)  Regular File mode: 0644 uid: 0
gid: 0

mount options
# 10.X.0.X:/vol/vz2/private on /vz/private type nfs
(rw,noatime,nodiratime,soft,timeo=60,nfsvers=3,retrans=2,rsize=8192,wsize=8192,actimeo=300,addr=10.X.0.X)

why does this happens with actimeo=300 . The second call in 1 minute
should be answered from cache is it ?. Can some tuning be done to
reduce this?.

Regards
Ranjith Ruban

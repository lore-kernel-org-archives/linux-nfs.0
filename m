Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:35554 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbDKJ6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Apr 2015 05:58:22 -0400
Received: by qkhg7 with SMTP id g7so72093362qkh.2
        for <linux-nfs@vger.kernel.org>; Sat, 11 Apr 2015 02:58:21 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 11 Apr 2015 11:58:21 +0200
Message-ID: <CALr0QzFXae_Hjki15o2gQoNDua0xWZjb3nDexBy-OFezK5-gXQ@mail.gmail.com>
Subject: Split NFS4 share on multiple servers
From: Prunk Dump <prunkdump@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NFS team,

On my network I share my users' home directories from a kerberized NFS4 server.

I would like to split this shared filesystem tree on 3 servers to
reduce server loading and increase storage capacity. I don't want file
replication, just distribution.

On this link :

http://www.ibm.com/developerworks/library/l-generic-nfs-mount/

I can read that "NFS version 4 provides a pseudo-tree mechanism that
enables a single mount of all NFSv4 exported entries"

I can't find documentation of this feature. Is it works on multiple
servers ? Is this possible to mount multiple NFS4 shares on a same
mount point without using a special file system like Unionfs or
Glusterfs ?

What is the preferred way of network administrators to distribute
their users' home directories through NFS4 ?

Thanks,
Baptiste.

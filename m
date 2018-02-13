Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:9529 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933919AbeBMKCU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 05:02:20 -0500
Received: from srvvm01.ac.aixigo.de (mail.ac.aixigo.de [172.19.96.11])
        by gate5a.ac.aixigo.de (OpenSMTPD) with ESMTPS id c2a1e6c3 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <linux-nfs@vger.kernel.org>;
        Tue, 13 Feb 2018 10:55:38 +0100 (CET)
To: linux-nfs@vger.kernel.org
From: Harald Dunkel <harald.dunkel@aixigo.de>
Subject: running NFS in LXC
Message-ID: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
Date: Tue, 13 Feb 2018 10:55:38 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

to support a HA setup I have a block device mirrored via
drbd on 2 hosts (write-through). The drbd Primary runs
the NFS service, using a dedicated IP address. NFS is not
running on the drbd Secondary.

To make this work I have to move several system files and
/var directories to a file system on the mirrored block
device as well. This is pretty clumsy, it breaks system
updates, etc.

Question: What if I run the NFS service in a LXC container
instead?

The idea is to put the whole service as a container on the
same block device as the NFS export partitions. In case of
a hardware failure on the Primary I can stop the NFS service,
make the Secondary to the new Primary and start the NFS
service on the other hardware again.

Do you expect some serious problems here? Please share your
thoughts. Every helpful comment is highly appreciated.


Harri

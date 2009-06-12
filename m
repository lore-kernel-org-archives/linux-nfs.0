From: "Bike & Snow" <bikeandsnow@googlemail.com>
Subject: NFS RDMA - how to stop the server?
Date: Fri, 12 Jun 2009 07:50:00 +0100
Message-ID: <a0c3604a0906112350x579ccf65x2e8e930d793f2d2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:55983 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbZFLGt7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2009 02:49:59 -0400
Received: by ewy6 with SMTP id 6so2702791ewy.37
        for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2009 23:50:01 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello

I'm working on a high availability NFS setup.

It's working very well when using UDP or TCP. However, when I use RDMA
(which is working nicely on it's own) I cannot get the NFS server to
stop. Because of this I cannot umount the filesystem and set the DRBD
block device to secondary.

I've found that when using RDMA, when I shut down the NFS kernel
server, this process is still running:
nfsd4

This is *not* running when using UDP or TCP based NFS.

Has anyone found a way around this? When shutting down the NFS kernel
server the svcrdma module is still in use:
svcrdma                37636  1

This is probably because /proc/fs/nfsd/portlist still has this entry:
rdma 20049

Is there a way of removing the entry from /proc/fs/nfsd/portlist?

I'm using Ubuntu 9.04. Tried kernels 2.6.28, .29 and .30.

Thanks

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.pingtimeout.net ([87.108.18.35]:49822 "EHLO
        mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752670AbeC1LON (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 07:14:13 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx1.pingtimeout.net (Postfix) with ESMTP id 8AAD815C838
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2018 14:04:59 +0300 (EEST)
Received: from mx1.pingtimeout.net ([127.0.0.1])
        by localhost (mx1.pingtimeout.net [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id jo7WNkOWNu03 for <linux-nfs@vger.kernel.org>;
        Wed, 28 Mar 2018 14:04:57 +0300 (EEST)
Received: from webmail.pingtimeout.net (ailin.pingtimeout.net [87.108.18.33])
        by mx1.pingtimeout.net (Postfix) with ESMTPA id CF68315C821
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2018 14:04:57 +0300 (EEST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Date: Wed, 28 Mar 2018 14:04:57 +0300
From: daedalus@pingtimeout.net
To: linux-nfs@vger.kernel.org
Subject: Regarding client fairness
Message-ID: <f9c6c1c493d0dde6c4a24afeca00fa5b@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I came across a rather annoying issue where a single NFS client caused 
resource starvation for NFS server. The server has several storage pools 
which are used, in this particular case a single client did fairly large 
read requests and effectively ate all nfsd threads on the server and 
during that other clients were getting hardly any I/O through to the 
other storage pool which was completely idle.

I then proceeded to make a simple testcase and noticed that reading a 
file with large blocksize causes NFS server to read using multiple 
threads, effectively consuming all nfsd threads on the server and 
causing starvation to other clients regardless of the share/backing disk 
they were accessing.

In my testcase a simple (ridiculous) dd was able to effectively reserve 
the entire NFS server for itself:

# dd if=fgsfds bs=1000M count=10000 iflag=direct

Also several similar dd runs with blocksize of 100M caused the same 
effect. During those dd-runs the server was responding at a very slow 
rate to any other requests by other clients (or to other NFS shares on 
different disks on the server).

My question here is that are there any methods to ensure client fairness 
with Linux NFS and/or are there some best common practices to ensure 
something like that. I think it would be pretty awesome if clients had 
some kind of limit/fairness that would be scoped like {client, 
share-on-server} so client which accesses a single share on a server 
(with large read IO requests) would not effectively cause denial of 
service for the entire NFS server but rather only to the share it is 
accessing and at same time other clients accessing different/same share 
would get fair amount of access to the data.

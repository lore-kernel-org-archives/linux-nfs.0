Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:33751 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241Ab3KMCaJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 21:30:09 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1VgQDU-0001Qi-Lo
	for linux-nfs@vger.kernel.org; Wed, 13 Nov 2013 03:30:04 +0100
Received: from static-50-46-232-229.evrt.wa.frontiernet.net ([static-50-46-232-229.evrt.wa.frontiernet.net])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 13 Nov 2013 03:30:04 +0100
Received: from harry by static-50-46-232-229.evrt.wa.frontiernet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 13 Nov 2013 03:30:04 +0100
To: linux-nfs@vger.kernel.org
From: Harry Edmon <harry@uw.edu>
Subject: Re: NFS over RDMA stops working for data larger than 812 Bytes
Date: Wed, 13 Nov 2013 02:18:35 +0000 (UTC)
Message-ID: <loom.20131113T031545-225@post.gmane.org>
References: <527CECD8.2000208@ims.co.at> <527CF1CF.3070101@ims.co.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Klemens Senn <klemens.senn@...> writes:

> 
> Hi,
> 
> I started setting up NFS over RDMA on a OpenSUSE 12.3 machine using the
> 3.7.10-1.16-default kernel.
> Mounting the NFS share works and getting a file with 812 Bytes succeeds.
> Reading 813 Bytes raises a Input/output error.
> 
> The export on the server side is done with
> /data
> 
172.16.100.0/24(rw,wdelay,crossmnt,insecure,no_root_squash,no_subtree_check,
fsid=0,mountpoint)
> 
> Following command is used for mounting the NFSv4 share:
>   mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.2:/ /mnt/
> 
> Testing the client side with older kernels stated that the mount is
> working properly with the 3.4.67 kernel. I continued testing with the
> 3.10.17 kernel and enabled the debug level and noticed the message
>   "server cheating in read reply: count 813 > recvd 0"


I am seeing the same thing on an Debian 7.2 RDMA client running the 3.12 
kernel.



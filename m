Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:24901 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab0KURKF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Nov 2010 12:10:05 -0500
From: Roland Dreier <rdreier@cisco.com>
To: Hiroyuki Sato <hiroysato@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [Q] I tried to mount nfs_server:/mnt volume, but It mounted another volume.
References: <AANLkTi=vpRm3MEiQZ39bw5XwfjL6CVbGEkAKWz-ynEp_@mail.gmail.com>
Date: Sun, 21 Nov 2010 09:10:00 -0800
In-Reply-To: <AANLkTi=vpRm3MEiQZ39bw5XwfjL6CVbGEkAKWz-ynEp_@mail.gmail.com>
	(Hiroyuki Sato's message of "Sun, 21 Nov 2010 21:23:31 +0900")
Message-ID: <adazkt2hac7.fsf@cisco.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Yes, as Boaz said, having two exports with fsid=0 is the problem:

 >   # cat /etc/exports
 >   /nfstest   192.168.100.0/255.255.255.0(fsid=0,rw,async,insecure,no_root_squash)
 >   /mnt       192.168.100.0/255.255.255.0(fsid=0,rw,async,insecure,no_root_squash)

you could have seen this in the server log from this:

 >   Nov 21 20:47:37 dell1435 mountd[3575]: /nfstest and /mnt have same
 > filehandle for 192.168.100.0/255.255.255.0, using first

 - R.

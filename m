From: Jiri Kortus <sumix-a4qEbw8STSk@public.gmane.org>
Subject: pNFS - Both DS and MDS on one machine (file layout)
Date: Mon, 17 May 2010 18:43:39 +0200
Message-ID: <4BF1723B.5020706@atlas.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:32966 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656Ab0EQQns (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 12:43:48 -0400
Received: from ns.sks3.muni.cz (sks.bb10.muni.cz [147.251.242.226] (may be forged))
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id o4HGhjp3028340
	for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 18:43:46 +0200
Received: from [147.251.209.121] (jk.sks3.muni.cz [147.251.209.121])
	by ns.sks3.muni.cz (Postfix) with ESMTP id 68ECE9E201
	for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 18:43:40 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I wonder if it is possible to run both MDS and DS on one machine under 
usual circumstances. I tried to install both of them on one machine with 
Debian Etch but I can't make them work.
I use the following configuration in /etc/exports:

/pnfs           
xxx.yyy.zzz.44(rw,fsid=0,no_root_squash,sync,no_subtree_check)
/pnfs           
aaa.bbb.ccc.74(rw,fsid=0,no_root_squash,sync,no_subtree_check)
/pnfs/storage   xxx.yyy.zzz.44(rw,no_root_squash,sync,no_subtree_check)
/pnfs/storage   aaa.bbb.ccc.74(rw,no_root_squash,sync,no_subtree_check)
/pnfs/export    aaa.bbb.ccc.74(rw,no_root_squash,sync,no_subtree_check,pnfs)

and /etc/spnfsd.conf:

[General]

Verbosity = 1
Stripe-size = 8192
Dense-striping = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
DS-Mount-Directory = /spnfs

[DataServers]

NumDS = 1

DS1_IP = xxx.yyy.zzz.44
DS1_PORT = 2049
DS1_ROOT = /storage
DS1_ID = 1

After mounting the pNFS export from the client (different machine) it 
doesn't use nfs file layout (I have spnfsd running on the server and 
nfslayoutdriver loaded on the client). When I try to create a file in 
the mounted directory (e. g. echo aaa>/mnt/testfile), I can't get any 
response, it just hangs (sometimes terminating it by ^C works, sometimes 
not). The file is created on the server, but is empty. I thought it 
could be related to running portmap but even if I run rpcbind instead of 
portmap, the problem doesn't disappear). Is there any problem with my 
configuration, is it a bug or MDS and DS just shouldn't be run on one 
machine?

Best regards,

Jiri Kortus

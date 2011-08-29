Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:46010 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab1H2P3f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 11:29:35 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id B96E36F5A4
	for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2011 17:04:21 +0200 (CEST)
Received: from [129.183.101.222] (pa-129.183.101.222.frec.bull.fr [129.183.101.222])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id ACF40272FD
	for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2011 17:04:19 +0200 (CEST)
Message-ID: <4E5BAB28.3070800@bull.net>
Date: Mon, 29 Aug 2011 17:07:20 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: sunrpc ref count leaks in nfs
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On a freshly installed RedHat 6.1 (2.6.32-131), I have sunrpc loaded 
with a reference counter = 1,
it is for the mount of sunrpc on /var/lib/nfs/rpc_pipefs.

If I want, I can unmout it and unload sunrpc.

If I execute a "service nfs start" and then a "service nfs stop"
(and I unmount /proc/fs/nfsd, I execute "service rpcidmapd stop", I remove
nfsd, lockd, nfs_acl, auth_rpcgss, exportfs, then "service rpcbind stop",
"service nfslock stop") then I am left with the reference counter of 
sunrpc = 4.
I.e. once used NFS, I cannot unload sunrpc.

Have you got a correction for this, please?

Thanks,

Zoltan Menyhart



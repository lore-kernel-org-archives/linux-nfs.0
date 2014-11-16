Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:57413 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433AbaKPAWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Nov 2014 19:22:00 -0500
Received: by mail-qg0-f48.google.com with SMTP id q108so13351121qgd.7
        for <linux-nfs@vger.kernel.org>; Sat, 15 Nov 2014 16:21:59 -0800 (PST)
Date: Sat, 15 Nov 2014 19:21:53 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: cl@qgenuity.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: Setting up NFS on Centos 6.6
Message-ID: <20141115192153.0ec58d54@synchrony.poochiereds.net>
In-Reply-To: <e7097d3e747a2a1e46c37d88cea3c8a2.squirrel@www.qgenuity.com>
References: <e7097d3e747a2a1e46c37d88cea3c8a2.squirrel@www.qgenuity.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 16 Nov 2014 00:07:23 +0900
cl@qgenuity.com wrote:

> Hello,
> 
> I'm having an unusual amount of trouble setting up Centos 6.6 as an NFS
> server. I have already created my exportfs file and run "chkconfig nfs
> on".
> 
> My copy of centos is running inside a virtual bubble. The server provider
> has loaded the nfsd module.
> 
> I run:
> chkconfig nfs on
> service rpcbind start
> service nfs start
> 
> The final command produces:
> # service nfs start
> FATAL: Module nfsd not found.
> FATAL: Error running install command for nfsd
> Starting NFS services:                                     [  OK  ]
> Starting NFS quotas:                                       [  OK  ]
> Starting NFS mountd:                                       [  OK  ]
> Starting NFS daemon:                                       [  OK  ]
> Starting RPC idmapd:                                       [  OK  ]
> 
> (I've been following the guide found here:
> http://openvz.org/NFS_server_inside_container which says that "module nfsd
> not found" is no problem.)
> 
> showmount -e produces:
> Export list for (server):
> /(directory) (address)
> 
> but when I try to mount
> mount -t nfs -v (address):/(dir) /mnt/nfs
> mount.nfs: timeout set for (date)
> mount.nfs: trying text-based options 'vers=4,addr=::1,clientaddr=::1'
> mount.nfs: mount(2): No such device
> mount.nfs: No such device
> 
> 
> Does anyone know what I need to do to get nfs working?
> 

-ENODEV is what you usually get when you can't plug in nfs.ko. Perhaps
your server provider needs to plug that in as well?

-- 
Jeff Layton <jlayton@poochiereds.net>

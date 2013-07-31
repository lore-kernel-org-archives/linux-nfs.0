Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f182.google.com ([209.85.215.182]:59950 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3GaGZO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jul 2013 02:25:14 -0400
Received: by mail-ea0-f182.google.com with SMTP id o10so128401eaj.27
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jul 2013 23:25:13 -0700 (PDT)
Received: from [192.168.43.130] ([31.21.165.149])
        by mx.google.com with ESMTPSA id ci50sm43684eeb.12.2013.07.30.23.25.11
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jul 2013 23:25:12 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: NFS4 server, performance and cache consistency in comparison with solaris.
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <E774E8EC-5CC0-436F-A8F3-0AB84534C316@gmail.com>
Date: Wed, 31 Jul 2013 08:25:09 +0200
Message-Id: <7385CFE1-E63F-45C5-A38C-59C6FC4F0C5C@gmail.com>
References: <E774E8EC-5CC0-436F-A8F3-0AB84534C316@gmail.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Actually, my mistake.
option "sync" on a client side also does not change something. Probably it is RHEL bug, but I see "sync" in /proc/mounts only when I mount with noac. When I mount with "sync", it is not present in /proc/mounts.

Anton.


On Jul 31, 2013, at 6:35 AM, Anton Starikov <ant.starikov@gmail.com> wrote:

> Hey, 
> 
> we are in the process of migration of our storage from solaris to linux (RHEL6) and I see some strange things, which depends on server side.
> 
> In our old solaris setup we have slower network (1GbE vs 10GbE), much slower storage than new one, but still when I export volume with default solaris options and mount on linux clients with options:
> rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,minorversion=0,local_lock=none
> 
> I have reasonable performance combined with reasonable cache consistency, i.e. when on one client some process keeps writing file (process opens file and writes to it while running, it also flushes stream like couple of times a second) on the NFS volume, on another client I can follow current state of this file practically realtime.
> 
> When I export from linux host with options: 
> 
> rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,no_acl,mountpoint,anonuid=65534,anongid=65534,sec=sys,rw,no_root_squash,no_all_squash (it is options as shown in /var/lib/nfs/etab),
> 
> and mount on linux clients with the same options as with old setup, I have great "dbench 4" performance (about 200Mb/s), but consistency is nonexistent, in the same case (one client keep writing to file, second is reading), on second client I can see state of file with delayed for 5-30 secs. Out of curiosity I tried to use "sync" in loop on a first client (where it writes) to flush cache, but it does not affect something. File isn't really large, but client updates it 2-4 times a sec.
> 
> All my attempts to improve consistency had two possible impacts:
> 
> 1) either still luck of consistency (like actimeo=0,lookupcache=none) and reasonable or good dbench results.
> 2) consistency is recovered (or almost recovered) (like sync, noac), but dbench results drops to 10MB/s or even less! 
> 
> Taking into account that mounting happens with the same options on a client side in both cases, it there some server-side trick with options?
> 
> Time is synchronised between hosts. 
> 
> Anton.


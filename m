Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:53559 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab3GaEfK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jul 2013 00:35:10 -0400
Received: by mail-we0-f171.google.com with SMTP id q55so172121wes.16
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jul 2013 21:35:08 -0700 (PDT)
Received: from [10.87.88.192] ([88.128.80.5])
        by mx.google.com with ESMTPSA id s19sm32622266wik.11.2013.07.30.21.35.06
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jul 2013 21:35:07 -0700 (PDT)
From: Anton Starikov <ant.starikov@gmail.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFS4 server, performance and cache consistency in comparison with solaris.
Message-Id: <E774E8EC-5CC0-436F-A8F3-0AB84534C316@gmail.com>
Date: Wed, 31 Jul 2013 06:35:03 +0200
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey, 

we are in the process of migration of our storage from solaris to linux (RHEL6) and I see some strange things, which depends on server side.

In our old solaris setup we have slower network (1GbE vs 10GbE), much slower storage than new one, but still when I export volume with default solaris options and mount on linux clients with options:
rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,minorversion=0,local_lock=none

I have reasonable performance combined with reasonable cache consistency, i.e. when on one client some process keeps writing file (process opens file and writes to it while running, it also flushes stream like couple of times a second) on the NFS volume, on another client I can follow current state of this file practically realtime.

When I export from linux host with options: 

rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,no_acl,mountpoint,anonuid=65534,anongid=65534,sec=sys,rw,no_root_squash,no_all_squash (it is options as shown in /var/lib/nfs/etab),

and mount on linux clients with the same options as with old setup, I have great "dbench 4" performance (about 200Mb/s), but consistency is nonexistent, in the same case (one client keep writing to file, second is reading), on second client I can see state of file with delayed for 5-30 secs. Out of curiosity I tried to use "sync" in loop on a first client (where it writes) to flush cache, but it does not affect something. File isn't really large, but client updates it 2-4 times a sec.

All my attempts to improve consistency had two possible impacts:

1) either still luck of consistency (like actimeo=0,lookupcache=none) and reasonable or good dbench results.
2) consistency is recovered (or almost recovered) (like sync, noac), but dbench results drops to 10MB/s or even less! 

Taking into account that mounting happens with the same options on a client side in both cases, it there some server-side trick with options?

Time is synchronised between hosts. 

Anton.
Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:47190 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaLOMZP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 07:25:15 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so8800000wiw.16
        for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2014 04:25:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAF1in6QVkgyuC7VQ5QdYnYtPRJgArDwg5sXtKiAvyszCcQoZ-g@mail.gmail.com>
References: <CAF1in6QVkgyuC7VQ5QdYnYtPRJgArDwg5sXtKiAvyszCcQoZ-g@mail.gmail.com>
Date: Mon, 15 Dec 2014 09:25:14 -0300
Message-ID: <CAF1in6RCyK4VMM3j1ZD=1D25+cFU9YGg-UhR-kuYcNWNk+Stzg@mail.gmail.com>
Subject: Fwd: NFS and Memory Buffers
From: Pablo Silva <psilvao@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Readers:

     My boss has entrusted me to analyze why the memory buffers are
not released a Linux server with Centos 6.4.?

    As informs me, the current reading is:


[root@bck ~]# free -m
             total       used       free     shared    buffers     cached
Mem:         15936      15788        147          0       6746        438
-/+ buffers/cache:       8604       7332
Swap:         2047          0       2047
[root@bck ~]#
[root@bck ~]#
[root@bck ~]# echo 3 > /proc/sys/vm/drop_caches && service snmpd
restart && free -m
Stopping snmpd:                                            [  OK  ]
Starting snmpd:                                            [  OK  ]
             total       used       free     shared    buffers     cached
Mem:         15936        509      15426          0         93         16
-/+ buffers/cache:        400      15536
Swap:         2047          0       2047
[root@bck ~]#

   I can not find the solution to release the memory buffer and cache
memory so grateful for any hint for finding the solution to this
"problem".

-Paul

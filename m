Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:53762 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757384AbZCTIw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2009 04:52:57 -0400
Message-ID: <49C3598E.4010704@vlnb.net>
Date: Fri, 20 Mar 2009 11:53:34 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
To: Wu Fengguang <wfg@linux.intel.com>
CC: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lukasz.jurewicz@gmail.com
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
References: <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <499B0994.8040000@vlnb.net> <20090219020542.GC5743@localhost> <49C2846D.5030500@vlnb.net>
In-Reply-To: <49C2846D.5030500@vlnb.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Vladislav Bolkhovitin, on 03/19/2009 08:44 PM wrote:
>   6. Unexpected result. In case, when all IO threads work in the same IO 
> context with CFQ increasing RA size *decreases* throughput. I think this 
> is, because RA requests performed as single big READ requests, while 
> requests coming from remote clients are much smaller in size (up to 
> 256K), so, when the read by RA data transferred to the remote client on 
> 100MB/s speed, the backstorage media gets rotated a bit, so the next 
> read request must wait the rotation latency (~0.1ms on 7200RPM).
                                                ^^^^^^^^^^^^^^^^^
Oops, it's RP*M*, hence the full rotation latency is in 60 times more, 
i.e. 8.3 ms.

Sorry,
Vlad


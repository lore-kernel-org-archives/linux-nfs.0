From: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Date: Tue, 17 Feb 2009 22:01:13 +0300
Message-ID: <499B0979.8050006@vlnb.net>
References: <20081112190227.GS26778@kernel.dk> <1226566313.199910.29888@de> <492BDAA9.4090405@vlnb.net> <20081125113048.GB16422@localhost> <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Moyer <jmoyer@redhat.com>,
	"Vitaly V. Bursov" <vitalyb-CNXmb7IdZIXO1JJkmS+EZg@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>,
	Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60408 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbZBQTBN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 14:01:13 -0500
In-Reply-To: <49946BE6.1040005-d+Crzxg7Rs0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Vladislav Bolkhovitin, on 02/12/2009 09:35 PM wrote:
> Additional interesting observation is how badly simultaneous read IO 
> streams are handled, if they aren't grouped in the corresponding IO 
> contexts. In test 3 the result was as low as 4(!)MB/s. Wu, Jens, do you 
> have any explanation on this? Why the inner tracks have so big preference?

I realized, there is another explanation: access becomes about to be 
completely random. I checked and it is true. Here is a sample "iostat -x 
3" output on the server:

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
            0.00    0.00    0.57   26.62    0.00   72.81

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s 
avgrq-sz avgqu-sz   await  svctm  %util
sda             710.00     0.00   47.33    0.00  6058.67     0.00 
128.00     0.12    2.59   2.51  11.87
sdb             710.00     0.00   47.33    0.00  6058.67     0.00 
128.00     3.99   84.34  21.13 100.00
sdc               0.00     0.00    0.00    0.00     0.00     0.00 
0.00     0.00    0.00   0.00   0.00
sdc1              0.00     0.00    0.00    0.00     0.00     0.00 
0.00     0.00    0.00   0.00   0.00
sdc2              0.00     0.00    0.00    0.00     0.00     0.00 
0.00     0.00    0.00   0.00   0.00
md0               0.00     0.00 1514.67    0.00 12117.33     0.00 
8.00     0.00    0.00   0.00   0.00
dm-0              0.00     0.00  757.33    0.00  6058.67     0.00 
8.00    32.87   43.41   1.32 100.00
dm-1              0.00     0.00    0.00    0.00     0.00     0.00 
0.00     0.00    0.00   0.00   0.00
dm-2              0.00     0.00  757.33    0.00  6058.67     0.00 
8.00    32.79   43.33   1.32 100.00

Thanks,
Vlad


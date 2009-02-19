From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Date: Thu, 19 Feb 2009 09:38:33 +0800
Message-ID: <20090219013833.GB5743@localhost>
References: <20081125113048.GB16422@localhost> <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <499B0979.8050006@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
	"Vitaly V. Bursov" <vitalyb-CNXmb7IdZIXO1JJkmS+EZg@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:30792 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751381AbZBSBio (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Feb 2009 20:38:44 -0500
In-Reply-To: <499B0979.8050006-d+Crzxg7Rs0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 17, 2009 at 10:01:13PM +0300, Vladislav Bolkhovitin wrote:
> Vladislav Bolkhovitin, on 02/12/2009 09:35 PM wrote:
>> Additional interesting observation is how badly simultaneous read IO  
>> streams are handled, if they aren't grouped in the corresponding IO  
>> contexts. In test 3 the result was as low as 4(!)MB/s. Wu, Jens, do you 
>> have any explanation on this? Why the inner tracks have so big 
>> preference?
>
> I realized, there is another explanation: access becomes about to be  
> completely random. I checked and it is true. Here is a sample "iostat -x  
> 3" output on the server:

Yes it's all about 64K sized reads. Is this the stripe size of md0?

Thanks,
Fengguang

> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            0.00    0.00    0.57   26.62    0.00   72.81
>
> Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s  
> avgrq-sz avgqu-sz   await  svctm  %util
> sda             710.00     0.00   47.33    0.00  6058.67     0.00 128.00  
>    0.12    2.59   2.51  11.87
> sdb             710.00     0.00   47.33    0.00  6058.67     0.00 128.00  
>    3.99   84.34  21.13 100.00
> sdc               0.00     0.00    0.00    0.00     0.00     0.00 0.00    
>  0.00    0.00   0.00   0.00
> sdc1              0.00     0.00    0.00    0.00     0.00     0.00 0.00    
>  0.00    0.00   0.00   0.00
> sdc2              0.00     0.00    0.00    0.00     0.00     0.00 0.00    
>  0.00    0.00   0.00   0.00
> md0               0.00     0.00 1514.67    0.00 12117.33     0.00 8.00    
>  0.00    0.00   0.00   0.00
> dm-0              0.00     0.00  757.33    0.00  6058.67     0.00 8.00    
> 32.87   43.41   1.32 100.00
> dm-1              0.00     0.00    0.00    0.00     0.00     0.00 0.00    
>  0.00    0.00   0.00   0.00
> dm-2              0.00     0.00  757.33    0.00  6058.67     0.00 8.00    
> 32.79   43.33   1.32 100.00
>
> Thanks,
> Vlad

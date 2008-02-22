From: "Sagar Borikar" <Sagar_Borikar-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: RE: nfs performance dropped when using 128 MB RAM
Date: Thu, 21 Feb 2008 19:50:39 -0800
Message-ID: <340C71CD25A7EB49BFA81AE8C8392667013239FC@BBY1EXM10.pmc_nt.nt.pmc-sierra.bc.ca>
References: <1202793191.2890.36.camel@serendib.melbourne.sgi.com> <340C71CD25A7EB49BFA81AE8C8392667013239CA@BBY1EXM10.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pmc216-241-226-184.pmc-sierra.bc.ca ([216.241.226.184]:41766
	"EHLO pmxedge2.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754245AbYBVDu3 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 22:50:29 -0500
Received: from bby1exg02.pmc_nt.nt.pmc-sierra.bc.ca (BBY1EXG02.pmc-sierra.bc.ca [216.241.231.167])
	by pmxedge2.pmc-sierra.bc.ca (8.13.4/8.12.7) with ESMTP id m1M3oMoB024225
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 19:50:23 -0800
In-Reply-To: <340C71CD25A7EB49BFA81AE8C8392667013239CA-WnaG5mLaJUuZWFWj0wbTyA@public.gmane.org_nt.nt.pmc-sierra.bc.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 
Folks,

Ok, I was able to crack the issue but in some odd way. I found that
pdflush was not able to flush the buffers in time because of which the
next write requests were stalled at the client side. I did following
changes to improve the performance. 

1. Changed the number of pdflush threads from default 2 to 4
2. Changed the CACHESIZE from 1024 to 8192 in fs/nfsd/nfscache.c
3. Changed SVC block size from 32k to 64k in include/linux/nfsd/const.h

After these changes, as expected I see much better performance but then
there is overshoot of at the start with less write size and later it
decreases. I captured the iozonelinux figures and they are as below

Excel output is below:
 
"Writer report"
        "4"  "8"  "16"  "32"  "64"
"65536"   1006667  1414856  1437128  1606784  1580778
"131072"   801006  1427892  1232945  1191835  1232504
"262144"   8555  16856  10093  16721  12607
"524288"   8136  13017  8419  11485  16160
"1048576"   6546  9635  10923  10611  10995
 
"Re-writer report"
        "4"  "8"  "16"  "32"  "64"
"65536"   1323668  1512831  1645809  1757521  1792708
"131072"   1119661  1299879  1367497  1423008  1427222
"262144"   3290  4173  3494  4158  4969
"524288"   3268  3398  3200  2899  3570
"1048576"   3126  3183  3646  3231  3890
 
"Reader report"
        "4"  "8"  "16"  "32"  "64"
"65536"   10790  11167  11123  10842  9409
"131072"   9270  10640  9084  9480  10958
"262144"   10136  11011  10881  8924  8911
"524288"   10947  9303  8567  9290  10853
"1048576"   10290  9499  10956  11156  11063
 
"Re-Reader report"
        "4"  "8"  "16"  "32"  "64"
"65536"   1770290  591736  686075  240800  236228
"131072"   753296  1219558  858200  1142548  1080169
"262144"   611654  308045  521012  403101  854802
"524288"   10834  9075  10613  9219  2725002
"1048576"   1410151  2341711  2635044  2869093  3004842
 
"Writer CPU utilization report (Zero values should be ignored)"
        "4"  "8"  "16"  "32"  "64"
"65536"     0.79   0.44   0.71   0.56   0.57
"131072"     0.75   0.78   0.57   0.67   0.72
"262144"     0.61   0.55   0.56   0.61   0.56
"524288"     0.68   0.58   0.59   0.26   0.59
"1048576"     0.61   0.68   0.67   0.68   0.68
 
"Re-writer CPU utilization report (Zero values should be ignored)"
        "4"  "8"  "16"  "32"  "64"
"65536"     0.70   0.66   0.59   0.52   0.70
"131072"     0.29   0.24   0.20   0.21   0.20
"262144"     0.25   0.22   0.19   0.20   0.20
"524288"     0.26   0.25   0.22   0.20   0.21
"1048576"     0.27   0.23   0.21   0.20   0.20
 
"Reader CPU utilization report (Zero values should be ignored)"
        "4"  "8"  "16"  "32"  "64"
"65536"     1.17   0.92   1.14   0.93   0.75
"131072"     1.00   1.17   0.80   0.79   1.07
"262144"     1.17   1.11   0.88   0.73   0.77
"524288"     1.19   0.90   0.77   0.78   0.84
"1048576"     1.13   0.91   0.99   0.94   0.87
 
"Re-Reader CPU utilization report (Zero values should be ignored)"
        "4"  "8"  "16"  "32"  "64"
"65536"    97.38  27.73  28.08  10.25   8.97
"131072"    41.15  57.14  33.57  43.21  44.13
"262144"    33.04  14.79  22.96  15.20  32.82
"524288"     1.15   0.81   0.93   0.75  93.97
"1048576"    71.14  99.75  99.18  99.22  99.61



I am surprised to see that write performance is better than read and
more interestingly re-write performance is degraded compared to write
performance.
Any cluses on this anomaly?

Thanks in advance

Sagar

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org
[mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Sagar Borikar
Sent: Tuesday, February 12, 2008 2:04 PM
To: linux-nfs@vger.kernel.org
Subject: nfs performance dropped when using 128 MB RAM

 Hello Folks,
 
I am not sure if this is the right place for this question. If not, I am
sorry and request you to direct me to right mailing list.
 
Currently I am working on a product which is derived from its ancestor
with more or less similar feature set and few additions. Other than
memory size, there are not hardware changes. The newer one is having 128
MB RAM while the ancestor was having 512 MB of RAM. The functionality
carried forward is also similar except for nfs. Both have gigabit
Ethernet interfaces
                 I am finding that nfs write performance has drastically
reduced say 1 MB/s or even it stalls for large file transfers to the
box. On the contrary it works fine with 512 MB of RAM. The CPU
utilization by nfsd as well as rpc.statd / rpc.mountd is also non
existent. Rather nfsd most of the time is sleeping for the data.  While
trying to analyse through ethereal, I observe that the write requests by
clients to the the server are periodic say around 1.5-2 minutes
interval. Till then the tcpdump captures that the handshake is going on
only for ack messages for wait requests. After then suddenly the burst
write transfer starts and within 4-5 seconds when the buffers are full
and no free memory is available, again it repeats the same cycle. When
poking in the meminfo stats, I found that there are no dirty pages and
write back buffers available before write bursts. As soon as the buffers
are available, nfs sends requests for further data and meminfo stats are
as it is. The free memory which is LowFree memory used by kernel data
structures in our case as High free memory is zero, is very less when
the buffers are not cleaned up. Once the burst data transfer finishes,
cached memory equal to that of previous buffered gets cleared as
expected. But Inactive memory is still high. I am attaching the tcpdump
logs with this mail. I am using rsize / wsize as 64k. Tried various
combinations of these sizes while mounting the nfs clients but it didn't
help.
I tried to check whether this problem is system wide but unfortunately
CIFS and FTP writes are pretty fast. so only nfs performance is affected
due to RAM size reduction. We have enabled socket buffer recycling in
Ethernet driver which block 600k of data for recycling. Even just to get
confirmation, I disabled the skb  recycling, even then the result was
same. I am not seeing this kind of behavior in other workstations with
128 MB of RAM and mips architecture.
Can anyone let me know, why the write requests are buffered and
periodically they get cleared? 
Also does nfs stack, requires special buffer availability for succeeding
write requests? 
 
Thanks and Regards,
Sagar Borikar
PMC sierra
 
 

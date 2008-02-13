From: "Sagar Borikar" <Sagar_Borikar-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Subject: RE: nfs performance dropped when using 128 MB RAM
Date: Tue, 12 Feb 2008 16:02:51 -0800
Message-ID: <340C71CD25A7EB49BFA81AE8C8392667D4C74B@BBY1EXM10.pmc_nt.nt.pmc-sierra.bc.ca>
References: <1202793191.2890.36.camel@serendib.melbourne.sgi.com> <340C71CD25A7EB49BFA81AE8C8392667013239CA@BBY1EXM10.pmc_nt.nt.pmc-sierra.bc.ca> <20080212182531.GB18625@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pmc216-241-226-183.pmc-sierra.bc.ca ([216.241.226.183]:60974
	"EHLO pmxedge1.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758722AbYBMAGJ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 19:06:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2008 at 12:33:41AM -0800, Sagar Borikar wrote:
>  Hello Folks,
> 
> I am not sure if this is the right place for this question. If not, I am
> sorry and request you to direct me to right mailing list.

This is the right list, but you're replying to an unrelated message,
which confuses those of us with threaded mail readers--no big deal, just
please be more careful about that next time.
 

> Currently I am working on a product which is derived from its ancestor
> with more or less similar feature set and few additions. Other than
> memory size, there are not hardware changes. The newer one is having 128
> MB RAM while the ancestor was having 512 MB of RAM. The functionality
> carried forward is also similar except for nfs. Both have gigabit
> Ethernet interfaces

This is a server, not a client?  What kernel are you using?

<Sagar> That's right. It is server and kernel is 2.6.18. I would appreciate any pointers / directions with this regard.

Thanks


>                  I am finding that nfs write performance has drastically
> reduced say 1 MB/s or even it stalls for large file transfers to the
> box. On the contrary it works fine with 512 MB of RAM. The CPU
> utilization by nfsd as well as rpc.statd / rpc.mountd is also non
> existent. Rather nfsd most of the time is sleeping for the data.  While
> trying to analyse through ethereal, I observe that the write requests by
> clients to the the server are periodic say around 1.5-2 minutes
> interval. Till then the tcpdump captures that the handshake is going on
> only for ack messages for wait requests. After then suddenly the burst
> write transfer starts and within 4-5 seconds when the buffers are full
> and no free memory is available, again it repeats the same cycle. When
> poking in the meminfo stats, I found that there are no dirty pages and
> write back buffers available before write bursts. As soon as the buffers
> are available, nfs sends requests for further data and meminfo stats are
> as it is. The free memory which is LowFree memory used by kernel data
> structures in our case as High free memory is zero, is very less when
> the buffers are not cleaned up. Once the burst data transfer finishes,
> cached memory equal to that of previous buffered gets cleared as
> expected. But Inactive memory is still high. I am attaching the tcpdump
> logs with this mail. I am using rsize / wsize as 64k. Tried various
> combinations of these sizes while mounting the nfs clients but it didn't
> help.
> I tried to check whether this problem is system wide but unfortunately
> CIFS and FTP writes are pretty fast. so only nfs performance is affected
> due to RAM size reduction. We have enabled socket buffer recycling in
> Ethernet driver which block 600k of data for recycling. Even just to get
> confirmation, I disabled the skb  recycling, even then the result was
> same. I am not seeing this kind of behavior in other workstations with
> 128 MB of RAM and mips architecture.
> Can anyone let me know, why the write requests are buffered and
> periodically they get cleared?
> Also does nfs stack, requires special buffer availability for succeeding
> write requests?
> 
> Thanks and Regards,
> Sagar Borikar
> PMC sierra
> 
> 




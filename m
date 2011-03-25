Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55168 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab1CYOcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2011 10:32:32 -0400
Date: Fri, 25 Mar 2011 22:32:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS page states & writeback
Message-ID: <20110325143229.GA12875@localhost>
References: <20110325012803.GA25052@quack.suse.cz>
 <20110325070054.GA5970@localhost>
 <20110325093957.GL26611@dastard>
 <20110325142253.GA11589@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110325142253.GA11589@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> However there is another problem. Look at the below graph. Even though
> the commits are sent to NFS server in relatively small size and evenly
> distributed in time (the green points), the commit COMPLETION events
> from the server are observed to be pretty bumpy over time (the blue
> points sitting on the red lines). This may not be easily fixable.. So
> we still have to live with bumpy NFS commit completions...
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/nfs-commit.png

The bumpy commit completions result in large fluctuations in estimated
write bandwidth (the red line):

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balance_dirty_pages-bandwidth.png

and fluctuated number of dirty pages (the red line):

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balance_dirty_pages-pages.png

And you can see the v6 patches still manages to keep the pause times
(the red points) under 100ms (hands down!):

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balance_dirty_pages-pause.png

Thanks,
Fengguang

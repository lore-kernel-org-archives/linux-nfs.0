Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:60907 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932297Ab2JESmV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Oct 2012 14:42:21 -0400
Date: Fri, 5 Oct 2012 14:42:15 -0400
From: Jim Rees <rees@umich.edu>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS daemon statistics in /proc/net/rpc/nfsd
Message-ID: <20121005184215.GA23015@umich.edu>
References: <20121005184856.4472a72e@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121005184856.4472a72e@harpe.intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Emmanuel Florac wrote:

  I noticed a long time ago that the thread information in
  /proc/net/rpc/nfsd isn't updated anymore since somewhere between the
  2.629 (information present) and 2.6.32 (information missing). It's
  quite easy to check:
  
  # grep th /proc/net/rpc/nfsd
  th 8 0 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
  
  All values are perpetually at zero. Unsurprising, because the
  update_thread_usage function in fs/nfsd/nfssvc.c isn't present anymore.
  
  I can't find any information about why this information was dropped;

It's easy to find this information from the git log. It also shows up in the
top half dozen or so results of a Google search on the same term.

% git log --grep update_thread_usage
commit 8bbfa9f3889b643fc7de82c0c761ef17097f8faf
Author: Greg Banks <gnb@sgi.com>
Date:   Tue Jan 13 21:26:34 2009 +1100

    knfsd: remove the nfsd thread busy histogram
    
    Stop gathering the data that feeds the 'th' line in /proc/net/rpc/nfsd
    because the questionable data provided is not worth the scalability
    impact of calculating it.  Instead, always report zeroes.  The current
    approach suffers from three major issues:
    
    1. update_thread_usage() increments buckets by call service
       time or call arrival time...in jiffies.  On lightly loaded
       machines, call service times are usually < 1 jiffy; on
       heavily loaded machines call arrival times will be << 1 jiffy.
       So a large portion of the updates to the buckets are rounded
       down to zero, and the histogram is undercounting.
    
    2. As seen previously on the nfs mailing list, the format in which
       the histogram is presented is cryptic, difficult to explain,
       and difficult to use.
    
    3. Updating the histogram requires taking a global spinlock and
       dirtying the global variables nfsd_last_call, nfsd_busy, and
       nfsdstats *twice* on every RPC call, which is a significant
       scaling limitation.
    
    Testing on a 4 CPU 4 NIC Altix using 4 IRIX clients each doing
    1K streaming reads at full line rate, shows the stats update code
    (inlined into nfsd()) takes about 1.7% of each CPU.  This patch drops
    the contribution from nfsd() into the profile noise.
    
    This patch is a forward-ported version of knfsd-remove-nfsd-threadstats
    which has been shipping in the SGI "Enhanced NFS" product since 2006.
    In that time, exactly one customer has noticed that the threadstats
    were missing.  It has been previously posted:
    
    http://article.gmane.org/gmane.linux.nfs/10376
    
    and more recently requested to be posted again.
    
    Signed-off-by: Greg Banks <gnb@sgi.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

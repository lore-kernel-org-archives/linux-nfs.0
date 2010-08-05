Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603Ab0HEVcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 17:32:35 -0400
Date: Thu, 5 Aug 2010 17:31:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100805213107.GB13821@fieldses.org>
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp>
 <20100802103214.7eea09eb@corrin.poochiereds.net>
 <20100802103620.5638dac1@corrin.poochiereds.net>
 <20100802181634.GD12637@fieldses.org>
 <201008030109.o73193bp094241@www262.sakura.ne.jp>
 <20100803154851.GA23467@fieldses.org>
 <201008040013.o740DmYK024832@www262.sakura.ne.jp>
 <20100804194045.GD18200@fieldses.org>
 <201008050110.o751AG18066496@www262.sakura.ne.jp>
 <20100805204612.GA13821@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100805204612.GA13821@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 05, 2010 at 04:46:12PM -0400, J. Bruce Fields wrote:
> On Thu, Aug 05, 2010 at 10:10:16AM +0900, Tetsuo Handa wrote:
> > J. Bruce Fields wrote:
> > > Maybe figuring out exactly hwere that is would help work out what's
> > > going on.  Doing
> > > 
> > > 	make net/sunrpc/svc.lst
> > > 
> > > then looking for c1356dd4 (or just mailing me svc.lst) could help.
> > 
> > "make net/sunrpc/svc.lst" failed due to following error.
> > 
> >   BFD: Dwarf Error: Abbrev offset (3238007024) greater than or equal to .debug_abbrev size (1607).
> > 
> > Manual printk() debug reported that
> > rqstp->rq_argp == rqstp->rq_resp == ZERO_SIZE_PTR and
> 
> Huh.  As far as I can tell that will only happen if you've not no nfsd
> versions defined; how is that happening?

OK, I think it's another startup-order problem: depending on how things
are started up, sv_nrthreads may already be nonzero, causing us to skip
nfsd_reset_versions(), so that the loop in __svc_create() ends up
leaving xdrsize 0, and then the kmalloc's in svc_prepare_thread() assign
ZERO_SIZE_PTR.

I need to think a little more about what we should be doing here.

--b.

> 
> --b.
> 
> > procp->pc_argsize == procp->pc_ressize == 4.
> > 
> > --- linux-2.6.35-next.orig/net/sunrpc/svc.c
> > +++ linux-2.6.35-next/net/sunrpc/svc.c
> > @@ -1084,6 +1084,11 @@ svc_process_common(struct svc_rqst *rqst
> >  	procp->pc_count++;
> > 
> >  	/* Initialize storage for argp and resp */
> > +	printk(KERN_INFO "rqstp=%p procp=%p\n", rqstp, procp);
> > +	printk(KERN_INFO "rqstp->rq_argp=%p procp->pc_argsize=%u\n",
> > +	       rqstp->rq_argp, procp->pc_argsize);
> > +	printk(KERN_INFO "rqstp->rq_resp=%p procp->pc_ressize=%u\n",
> > +	       rqstp->rq_resp, procp->pc_ressize);
> >  	memset(rqstp->rq_argp, 0, procp->pc_argsize);
> >  	memset(rqstp->rq_resp, 0, procp->pc_ressize);
> >  
> > 
> > [   37.669174] NET: Registered protocol family 10
> > [   38.080725] svc: failed to register lockdv1 RPC service (errno 97).
> > [  122.895707] rqstp=dcb91000 procp=c154ca20
> > [  122.896533] rqstp->rq_argp=00000010 procp->pc_argsize=4
> > [  122.897484] rqstp->rq_resp=00000010 procp->pc_ressize=4
> > [  122.898609] BUG: unable to handle kernel NULL pointer dereference at 00000010
> > [  122.899964] IP: [<c1356e80>] svc_process_common+0x370/0x640
> > [  122.900493] *pde = 00000000 
> > [  122.900493] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> > [  122.923308] last sysfs file: /sys/devices/pci0000:00/0000:00:10.0/host0/target0:0:1/0:0:1:0/type
> > [  122.923308] Modules linked in: nfs ipv6 pcnet32
> > 
> > > OK, I wonder if Sarge didn't yet mount the nfsd filesystem on
> > > /proc/fs/nfsd.
> > 
> > According to /proc/mounts , the nfsd filesystem is not mounted on
> > /proc/fs/nfsd . But mounting it manually before starting nfsd did not help.
> > 
> > Regards.

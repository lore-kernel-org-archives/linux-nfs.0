From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 17:56:10 -0500
Message-ID: <1232578570.7692.96.camel@heimdal.trondhjem.org>
References: <4970B451.4080201@RedHat.com>
	 <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	 <497757D1.7090908@RedHat.com>
	 <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	 <49777988.6010401@RedHat.com>
	 <A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
	 <4977A385.8000406@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:49925 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503AbZAUW4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jan 2009 17:56:18 -0500
In-Reply-To: <4977A385.8000406-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-01-22 at 09:36 +1100, Greg Banks wrote:
> Chuck Lever wrote:
> >
> >
> > I think we need to visit this issue on a case-by-case basis.   
> > Sometimes dprintk is appropriate.  Sometimes printk(KERN_ERR).   
> > Sometimes a performance metric.
> Well said.
> 
> > Trond has always maintained that dprintk() is best for developers, but  
> > probably inappropriate for field debugging,
> It's not a perfect tool but it beats nothing at all.
> >  and I think that may also  
> > apply to trace points.  
> It depends on whether distros can be convinced to enable it by default,
> and install by default any necessary userspace infrastructure.   The
> most important thing for field debugging is Just Knowing that you have
> all the bits necessary to perform useful debugging without having to
> find some RPM that matches the kernel that the machine is actually
> running now, and not the one that was present when the machine was
> installed.

Which is precisely why dprintk() is such a bad choice as a basis for a
set of trace points: every new patch and bugfix that the distro applies
will result in a reshuffling of the trace points as code is cleaned up
and moved around or removed entirely.

Cheers
  Trond


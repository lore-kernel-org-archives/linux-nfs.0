Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f43.google.com ([209.85.219.43]:53808 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IEWeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 18:34:25 -0400
Received: by mail-oa0-f43.google.com with SMTP id i10so3152985oag.30
        for <linux-nfs@vger.kernel.org>; Thu, 05 Sep 2013 15:34:25 -0700 (PDT)
Date: Thu, 5 Sep 2013 17:34:20 -0500
From: Quentin Barnes <qbarnes@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
Message-ID: <20130905223420.GA23192@gmail.com>
References: <20130905162110.GA17920@gmail.com>
 <20130905170303.GB17330@us.ibm.com>
 <20130905191139.GA20830@gmail.com>
 <1378411320.5450.27.camel@leira.trondhjem.org>
 <20130905213649.GA21944@gmail.com>
 <1378418243.5450.29.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378418243.5450.29.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 05, 2013 at 09:57:24PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-09-05 at 16:36 -0500, Quentin Barnes wrote:
> > On Thu, Sep 05, 2013 at 08:02:01PM +0000, Myklebust, Trond wrote:
> > > On Thu, 2013-09-05 at 14:11 -0500, Quentin Barnes wrote:
> > > > On Thu, Sep 05, 2013 at 12:03:03PM -0500, Malahal Naineni wrote:
> > > > > Neil Brown posted a patch couple days ago for this!
> > > > > 
> > > > > http://thread.gmane.org/gmane.linux.nfs/58473
> > > > 
> > > > I tried Neil's patch on a v3.11 kernel.  The rebuilt kernel still
> > > > exhibited the same 1000s of WRITEs/sec problem.
> > > > 
> > > > Any other ideas?
> > > 
> > > Yes. Please try the attached patch.
> > 
> > Great!  That did the trick!
> > 
> > Do you feel this patch could be worthy of pushing it upstream in its
> > current state or was it just to verify a theory?
> > 
> > 
> > In comparing the nfs_flush_incompatible() implementations between
> > RHEL5 and v3.11 (without your patch), the guts of the algorithm seem
> > more or less logically equivalent to me on whether or not to flush
> > the page.  Also, when and where nfs_flush_incompatible() is invoked
> > seems the same.  Would you provide a very brief pointer to clue me
> > in as to why this problem didn't also manifest circa 2.6.18 days?
> 
> There was no nfs_vm_page_mkwrite() to handle page faults in the 2.6.18
> days, and so the risk was that your mmapped writes could end up being
> sent with the wrong credentials.

Ah!  You're right that nfs_vm_page_mkwrite() was missing from
the original 2.6.18, so that makes sense, however, Red Hat had
backported that function starting with their RHEL5.9(*) kernels,
yet the problem doesn't manifest on RHEL5.9.  Maybe the answer lies
somewhere in RHEL5.9's do_wp_page(), or up that call path, but
glancing through it, it all looks pretty close though.


(*) That was the source I using when comparing with the 3.11 source
when studying your patch since it was the last kernel known to me
without the problem.

> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

Quentin

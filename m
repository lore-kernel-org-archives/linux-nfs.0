Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 1wt.eu ([62.212.114.60]:33912 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbaIEJnJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2014 05:43:09 -0400
Date: Fri, 5 Sep 2014 11:33:46 +0200
From: Willy Tarreau <w@1wt.eu>
To: Luis Henriques <luis.henriques@canonical.com>
Cc: NeilBrown <neilb@suse.de>, stable@vger.kernel.org,
        NFS <linux-nfs@vger.kernel.org>, Lars Behrens <lars.behrens@pi.uka.de>
Subject: Re: Incorrect backport to 2.6.32-stable - NFSD regression.
Message-ID: <20140905093346.GC15759@1wt.eu>
References: <20140903112843.66bcd6dd@notabene.brown> <20140905092105.GA6614@hercules>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140905092105.GA6614@hercules>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,

On Fri, Sep 05, 2014 at 10:21:05AM +0100, Luis Henriques wrote:
> (Adding Willy to the CC list, in case he misses this email.)

Thank you Luis, I indeed missed it!

> On Wed, Sep 03, 2014 at 11:28:43AM +1000, NeilBrown wrote:
> > 
> > 2.6.32.30 contains:
> > 
> > commit 63d059e73ff4574b79bd8aa252b5fc00b6326ddf
> > Author: NeilBrown <neilb@suse.de>
> > Date:   Wed Feb 16 13:08:35 2011 +1100
> > 
> >     nfsd: correctly handle return value from nfsd_map_name_to_*
> >     
> >     commit 47c85291d3dd1a51501555000b90f8e281a0458e upstream.
> >     
> >     These functions return an nfs status, not a host_err.  So don't
> >     try to convert  before returning.
> >     
> >     This is a regression introduced by
> >     3c726023402a2f3b28f49b9d90ebf9e71151157d; I fixed up two of the callers,
> >     but missed these two.
> >     
> >     Reported-by: Herbert Poetzl <herbert@13thfloor.at>
> >     Signed-off-by: NeilBrown <neilb@suse.de>
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> > 
> > 
> > But it does *not* contain a backport of
> > 3c726023402a2f3b28f49b9d90ebf9e71151157d.
> > 
> > So rather an fixing a regression, it introduces one.
> > 
> > This patch should be reverted.

Thanks Neil, I'm queuing this request for next version. I'm slowly
catching up from my move and hope to be able to deliver it "soon".

Best regards,
willy

